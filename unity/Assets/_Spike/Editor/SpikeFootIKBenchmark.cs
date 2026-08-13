using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

// Spike ADR-003: mide el foot IK de Unity contra el estandar del Benchmark
// Biomecanico, con EL MISMO protocolo que godot/tools/footik_benchmark.gd.
// Si el protocolo no es identico, los dos numeros no se pueden poner uno al
// lado del otro.
//
// Protocolo compartido:
//   - Camara ORTOGRAFICA con su "arriba" en la normal del terreno y su eje
//     de vista DENTRO del plano del terreno: la superficie queda como una
//     linea horizontal exacta en la imagen.
//   - Se ocultan el otro personaje, las MALLAS del suelo (los colliders
//     quedan, para que el IK tenga contra que tirar rayos) y el hacha, que
//     cuelga por debajo de los pies.
//   - PENETRACION = distancia del pixel MAS BAJO de la silueta a la linea
//     del suelo, en metros. Negativa = el pie atraviesa el piso.
//   - 16 muestras por terreno; el "apoyo" es el 40% de muestras con mayor
//     penetracion.
//
// Se mide sobre el render y no leyendo huesos por la misma razon que del
// lado Godot: es el canal que refleja el resultado final, sin importar en
// que etapa del pipeline lo escribio cada motor.
//
// CONTROL: al final se baja al personaje 10 cm y se vuelve a medir. La
// penetracion tiene que cambiar ~10 cm. Si no cambia, el instrumento esta
// ciego y los otros numeros no valen -- del lado Godot esa leccion costo
// medio dia.
//
// Uso:
//   Unity.exe -batchmode -projectPath <unity> -executeMethod SpikeFootIKBenchmark.Run
//   (agregar -noik para la linea base sin foot IK)
public static class SpikeFootIKBenchmark
{
    public const string ScenePath = "Assets/_Spike/SpikeSlope.unity";

    public const int Samples = 16;
    public const float FlatZ = -5f;
    public const float RampZ = 8f;
    public const int RootFrames = 180;
    public const float OrthoSize = 1.80f;   // extension vertical TOTAL, como en Godot
    public const float FocusUp = 0.55f;
    public const int Width = 800;
    public const int Height = 600;
    public const float WalkSpeedParam = 2f;

    private const string FlagKey = "SpikeFootIKBenchmark.Pending";

    public static void Run()
    {
        EditorSceneManager.OpenScene(ScenePath, OpenSceneMode.Single);
        SessionState.SetBool(FlagKey, true);
        EditorApplication.EnterPlaymode();
    }

    [InitializeOnLoadMethod]
    private static void Hook()
    {
        EditorApplication.playModeStateChanged += state =>
        {
            if (state != PlayModeStateChange.EnteredPlayMode) return;
            if (!SessionState.GetBool(FlagKey, false)) return;
            SessionState.SetBool(FlagKey, false);
            var go = new GameObject("SpikeBenchDriver");
            Object.DontDestroyOnLoad(go);
            go.AddComponent<SpikeBenchDriver>();
        };
    }
}

public class SpikeBenchDriver : MonoBehaviour
{
    private static readonly Color Bg = new Color(0f, 0.6f, 0f);

    private Camera _cam;
    private RenderTexture _rt;
    private Texture2D _shot;
    private float _mpp;
    private bool _failed;

    private IEnumerator Start()
    {
        yield return null;
        yield return null;
        yield return StartCoroutine(Bench());
        Debug.Log("[bench] listo");
        EditorApplication.Exit(_failed ? 1 : 0);
    }

    private void Fail(string msg)
    {
        _failed = true;
        Debug.LogError("[bench] " + msg);
    }

    private IEnumerator Bench()
    {
        bool noik = System.Array.IndexOf(System.Environment.GetCommandLineArgs(), "-noik") >= 0;

        var dagna = GameObject.Find("Dagna_Placeholder");
        if (dagna == null) { Fail("no se encontro Dagna_Placeholder"); yield break; }

        var animator = dagna.GetComponentInChildren<Animator>();
        if (animator == null) { Fail("Dagna sin Animator"); yield break; }

        var walk = dagna.GetComponent<SpikeCompanionWalk>();
        var controller = dagna.GetComponent<CharacterController>();
        var footIK = dagna.GetComponent<SpikeFootIK>();

        if (noik && footIK != null) footIK.enabled = false;
        Debug.Log(noik ? ">>> FOOT IK APAGADO (linea base: la animacion sola)"
                       : ">>> FOOT IK ACTIVO (Animator IK de Unity)");

        // --- Raiz continua, con el driver todavia vivo ---
        Vector3 prev = dagna.transform.position;
        var steps = new List<float>();
        // Se muestrea por FRAME y no por FixedUpdate: SpikeCompanionWalk
        // mueve al personaje en Update(). Midiendo en fisica salia un
        // desvio del 442%, que era del muestreo, no del movimiento.
        for (int i = 0; i < SpikeFootIKBenchmark.RootFrames; i++)
        {
            yield return null;
            Vector3 p = dagna.transform.position;
            steps.Add((p - prev).magnitude);
            prev = p;
        }
        float mean = 0f;
        foreach (var s in steps) mean += s;
        mean /= steps.Count;
        float sd = 0f;
        foreach (var s in steps) sd += (s - mean) * (s - mean);
        sd = Mathf.Sqrt(sd / steps.Count);
        Debug.Log(string.Format("[bench] RAIZ  avance medio {0:F4} m/frame  desvio {1:F4} m  ({2:F1}%)",
            mean, sd, 100f * sd / Mathf.Max(mean, 0.0001f)));

        // --- Quieta, controlada a mano ---
        if (walk != null) walk.enabled = false;
        if (controller != null) controller.enabled = false;
        animator.cullingMode = AnimatorCullingMode.AlwaysAnimate;
        animator.applyRootMotion = false;
        animator.speed = 0f;
        animator.SetFloat("Speed", SpikeFootIKBenchmark.WalkSpeedParam);
        animator.SetFloat("MotionSpeed", 1f);
        animator.SetBool("Grounded", true);
        yield return null;

        PrepareScene(dagna);

        int stateHash = animator.GetCurrentAnimatorStateInfo(0).fullPathHash;

        // --- Calibracion del offset del tobillo, igual que del lado Godot.
        // SpikeFootIK.cs planta el TOBILLO a `footOffsetY` sobre el punto de
        // impacto, y ese valor viene fijo en 0.05 -- el mismo defecto que
        // tenia nuestro lado Godot antes de calibrarlo. Comparar sin
        // calibrar los dos seria comparar nuestras calibraciones, no los
        // motores. Se barre por reflexion para no tocar la escena.
        var field = typeof(SpikeFootIK).GetField("footOffsetY",
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        if (field != null && footIK != null)
        {
            float best = 0.05f;
            float bestAbs = float.MaxValue;
            foreach (float off in new float[] { 0.17f, 0.19f, 0.21f, 0.23f, 0.25f })
            {
                field.SetValue(footIK, off);
                yield return null;
                float pen = 0f;
                yield return Measure(dagna, animator, stateHash, SpikeFootIKBenchmark.FlatZ,
                    string.Format("CALIB footOffsetY={0:F2}", off), 0f, r => pen = r);
                if (Mathf.Abs(pen) < bestAbs) { bestAbs = Mathf.Abs(pen); best = off; }
            }
            field.SetValue(footIK, best);
            yield return null;
            Debug.Log(string.Format("[bench] CALIBRADO: footOffsetY = {0:F2} (penetracion {1:F4} m en plano)",
                best, bestAbs));
        }
        else
        {
            Debug.Log("[bench] no se pudo barrer footOffsetY por reflexion");
        }

        float flat = 0f, ramp = 0f;
        yield return Measure(dagna, animator, stateHash, SpikeFootIKBenchmark.FlatZ, "PLANO", 0f,
            r => flat = r);
        yield return Measure(dagna, animator, stateHash, SpikeFootIKBenchmark.RampZ, "RAMPA 21.8 grados", 0f,
            r => ramp = r);

        Debug.Log(string.Format("[bench] PLANO -> RAMPA = {0:+0.0000;-0.0000} m  (0 = se apoya igual de bien en pendiente)",
            ramp - flat));

        // --- CONTROL: se hunde al personaje 10 cm a mano y la penetracion
        // medida tiene que empeorar ~0.10 m. Valida que el instrumento ve
        // la geometria Y que la conversion pixel->metro esta bien escalada.
        //
        // OJO: el control corre con el FOOT IK APAGADO a proposito. Con el
        // IK activo, hundir el cuerpo hace que el IK vuelva a plantar el
        // pie en la superficie -- la penetracion casi no cambia y el
        // control da falso negativo. Eso paso en la primera corrida: 0.0205
        // en vez de 0.10, y no era el instrumento, era el IK haciendo su
        // trabajo.
        if (footIK != null) footIK.enabled = false;
        yield return null;
        float flatNoIK = 0f, sunk = 0f;
        yield return Measure(dagna, animator, stateHash, SpikeFootIKBenchmark.FlatZ, "CONTROL base (sin IK)", 0f,
            r => flatNoIK = r);
        yield return Measure(dagna, animator, stateHash, SpikeFootIKBenchmark.FlatZ, "CONTROL hundida 0.10 m (sin IK)", -0.10f,
            r => sunk = r);
        float delta = flatNoIK - sunk;
        Debug.Log(string.Format("[bench] CONTROL: la penetracion cambio {0:F4} m al hundirla 0.10 m -> {1}",
            delta, (Mathf.Abs(delta - 0.10f) < 0.02f) ? "INSTRUMENTO VALIDO" : "SOSPECHOSO"));
    }

    private void PrepareScene(GameObject dagna)
    {
        var player = GameObject.Find("PlayerArmature");
        if (player != null)
            foreach (var r in player.GetComponentsInChildren<Renderer>()) r.enabled = false;

        var slope = GameObject.Find("Slope_Root");
        if (slope != null)
            foreach (var r in slope.GetComponentsInChildren<Renderer>()) r.enabled = false;

        // El hacha cuelga por debajo de los pies: si queda visible, el pixel
        // mas bajo de la silueta es el filo y estariamos midiendo el arma.
        foreach (var r in dagna.GetComponentsInChildren<Renderer>())
            if (r.name.ToLower().Contains("axe")) r.enabled = false;

        var camGO = new GameObject("BenchCam");
        _cam = camGO.AddComponent<Camera>();
        _cam.orthographic = true;
        // OJO: en Unity `orthographicSize` es la MITAD de la extension
        // vertical; en Godot `size` es la extension entera. Sin esta mitad,
        // la escala de metros por pixel sale al doble y los dos motores no
        // serian comparables.
        _cam.orthographicSize = SpikeFootIKBenchmark.OrthoSize * 0.5f;
        _cam.clearFlags = CameraClearFlags.SolidColor;
        _cam.backgroundColor = Bg;
        _cam.nearClipPlane = 0.05f;

        _rt = new RenderTexture(SpikeFootIKBenchmark.Width, SpikeFootIKBenchmark.Height, 24);
        _shot = new Texture2D(SpikeFootIKBenchmark.Width, SpikeFootIKBenchmark.Height, TextureFormat.RGB24, false);
        _mpp = SpikeFootIKBenchmark.OrthoSize / SpikeFootIKBenchmark.Height;
    }

    private IEnumerator Measure(GameObject dagna, Animator animator, int stateHash,
        float z, string label, float sink, System.Action<float> result)
    {
        // Plantada por raycast, igual que del lado Godot.
        if (!Physics.Raycast(new Vector3(0f, 12f, z), Vector3.down, out RaycastHit probe, 40f))
        {
            Fail("no hay terreno en z=" + z);
            result(0f);
            yield break;
        }
        dagna.transform.position = probe.point + Vector3.up * sink;
        dagna.transform.rotation = Quaternion.LookRotation(Vector3.forward, Vector3.up);
        yield return null;

        Vector3 p = probe.point;
        Vector3 n = probe.normal;
        // Eje transversal a la pendiente: vive dentro del plano del terreno.
        Vector3 side = Vector3.Cross(n, Vector3.forward).normalized;

        var samples = new List<float>();
        int clipped = 0;
        for (int i = 0; i < SpikeFootIKBenchmark.Samples; i++)
        {
            animator.Play(stateHash, 0, i / (float)SpikeFootIKBenchmark.Samples);
            yield return null;
            yield return null;

            Vector3 focus = p + n * SpikeFootIKBenchmark.FocusUp;
            _cam.transform.position = focus + side * 3f;
            _cam.transform.rotation = Quaternion.LookRotation(focus - _cam.transform.position, n);

            _cam.targetTexture = _rt;
            _cam.Render();
            RenderTexture.active = _rt;
            _shot.ReadPixels(new Rect(0, 0, SpikeFootIKBenchmark.Width, SpikeFootIKBenchmark.Height), 0, 0);
            _shot.Apply();
            RenderTexture.active = null;

            int low = LowestSilhouetteRow(_shot);
            if (low < 0) continue;
            if (low <= 1) { clipped++; continue; }

            float groundRow = _cam.WorldToScreenPoint(p).y;
            samples.Add((low - groundRow) * _mpp);
            _cam.targetTexture = null;
        }

        if (samples.Count == 0)
        {
            Fail("no se pudo segmentar la silueta en " + label);
            result(0f);
            yield break;
        }

        samples.Sort();
        int stanceCount = Mathf.Max(1, Mathf.RoundToInt(samples.Count * 0.4f));
        float sum = 0f;
        for (int i = 0; i < stanceCount; i++) sum += samples[i];
        float meanPen = sum / stanceCount;

        Debug.Log(string.Format("[bench] {0}  ({1} muestras utiles, {2} en apoyo, {3} descartadas por recorte)",
            label, samples.Count, stanceCount, clipped));
        Debug.Log(string.Format("[bench]    penetracion  media {0:+0.0000;-0.0000} m   peor {1:+0.0000;-0.0000} m   (negativo = atraviesa el piso)",
            meanPen, samples[0]));
        result(meanPen);
    }

    // Fila (en coordenadas de textura, con el 0 abajo) del pixel mas bajo
    // que no sea el fondo.
    private static int LowestSilhouetteRow(Texture2D tex)
    {
        var px = tex.GetPixels32();
        int w = tex.width, h = tex.height;
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x += 2)
            {
                Color32 c = px[y * w + x];
                if (Mathf.Abs(c.r / 255f - Bg.r) > 0.12f ||
                    Mathf.Abs(c.g / 255f - Bg.g) > 0.12f ||
                    Mathf.Abs(c.b / 255f - Bg.b) > 0.12f)
                    return y;
            }
        }
        return -1;
    }
}
