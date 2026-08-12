using System.Collections;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

// Spike ADR-003: tira de frames del ciclo de caminata de Dagna del lado
// Unity, para comparar cuadro a cuadro contra la tira equivalente de Godot
// (godot/tools/frame_strip.gd).
//
// El protocolo es el MISMO en los dos motores, si no la comparacion no
// significa nada:
//   - MISMO punto de la rampa (Dagna quieta ahi, sin driver de traslacion),
//     asi lo que se compara es la animacion + el foot IK, no el timing.
//   - MISMA cantidad de frames sobre UN ciclo completo.
//   - MISMA fase inicial: el contacto del talon izquierdo, DETECTADO
//     midiendo el hueso, no elegido a ojo.
//   - MISMA camara relativa al personaje y misma resolucion.
//
// Corre en PLAY MODE a proposito: el foot IK de Unity vive en
// OnAnimatorIK, que en modo edicion no se dispara. Sin play mode la tira
// de Unity saldria sin IK y la de Godot con IK.
//
// Uso:
//   Unity.exe -batchmode -projectPath <unity> -executeMethod SpikeFrameStrip.Run
//   (sin -quit: el driver de runtime cierra el editor cuando termina)
public static class SpikeFrameStrip
{
    public const string ScenePath = "Assets/_Spike/SpikeSlope.unity";
    public const string OutDir = "test_out/strip";

    public const int Frames = 8;
    public const int Samples = 120;
    public const float RampZ = 8f;
    public const float CamSide = 4.2f;
    public const float CamUp = 0.9f;
    public const float LookUp = 0.85f;
    public const float CamFov = 32f;
    public const int Width = 480;
    public const int Height = 600;

    // Umbral del blend tree de Starter Assets: 0 = idle, 2 = walk, 6 = run.
    public const float WalkSpeedParam = 2f;

    private const string FlagKey = "SpikeFrameStrip.Pending";

    public static void Run()
    {
        EditorSceneManager.OpenScene(ScenePath, OpenSceneMode.Single);
        // SessionState sobrevive el domain reload que provoca entrar a play
        // mode; una variable estatica comun no.
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

            var go = new GameObject("SpikeStripDriver");
            Object.DontDestroyOnLoad(go);
            go.AddComponent<SpikeStripDriver>();
        };
    }
}

public class SpikeStripDriver : MonoBehaviour
{
    private IEnumerator Start()
    {
        yield return null;
        yield return null;
        yield return StartCoroutine(Capture());
        Debug.Log("[strip] listo");
        EditorApplication.Exit(_failed ? 1 : 0);
    }

    private bool _failed;

    private void Fail(string msg)
    {
        _failed = true;
        Debug.LogError("[strip] " + msg);
    }

    private IEnumerator Capture()
    {
        var dagna = GameObject.Find("Dagna_Placeholder");
        if (dagna == null) { Fail("no se encontro Dagna_Placeholder"); yield break; }

        var animator = dagna.GetComponentInChildren<Animator>();
        if (animator == null) { Fail("Dagna sin Animator"); yield break; }

        // Se apaga el driver de traslacion y el CharacterController: la
        // queremos quieta en un punto conocido de la rampa.
        var walk = dagna.GetComponent<SpikeCompanionWalk>();
        if (walk != null) walk.enabled = false;
        var controller = dagna.GetComponent<CharacterController>();
        if (controller != null) controller.enabled = false;

        // Plantada sobre la superficie real de la rampa por raycast, no por
        // trigonometria a mano: el mesh manda.
        Vector3 probe = new Vector3(0f, 12f, SpikeFrameStrip.RampZ);
        RaycastHit ground;
        if (!Physics.Raycast(probe, Vector3.down, out ground, 40f))
        {
            Fail("el raycast no encontro la rampa en z=" + SpikeFrameStrip.RampZ);
            yield break;
        }
        dagna.transform.position = ground.point;
        // Mirando rampa arriba, que es como camina en la corrida real.
        dagna.transform.rotation = Quaternion.LookRotation(Vector3.forward, Vector3.up);

        var footIK = dagna.GetComponent<SpikeFootIK>();

        // Animator manejado a mano: speed 0 y la fase fijada con Play(); asi
        // el muestreo no depende del framerate.
        animator.applyRootMotion = false;
        animator.speed = 0f;
        // CLAVE: el prefab de Starter Assets viene con culling, y en
        // batchmode (con la MainCamera mirando a otro lado tras teleportarla)
        // Unity deja de escribir los Transform de los huesos. El pose se
        // veia bien en el render pero GetBoneTransform devolvia siempre lo
        // mismo, y el barrido del contacto daba recorrido = 0.
        animator.cullingMode = AnimatorCullingMode.AlwaysAnimate;
        animator.SetFloat("Speed", SpikeFrameStrip.WalkSpeedParam);
        animator.SetFloat("MotionSpeed", 1f);
        animator.SetBool("Grounded", true);
        yield return null;

        int stateHash = animator.GetCurrentAnimatorStateInfo(0).fullPathHash;

        // --- Fase 0 = contacto del talon izquierdo ---
        // El IK se apaga mientras se busca: pega el pie al suelo cada frame
        // y aplasta el rango del hueso, dejando el contacto indetectable.
        // Unity mira a +Z, asi que el pie mas adelantado es el de Z local
        // MAXIMA (en Godot, que mira a -Z, es la minima).
        if (footIK != null) footIK.enabled = false;

        Transform lf = animator.GetBoneTransform(HumanBodyBones.LeftFoot);
        if (lf == null) { Fail("el avatar no expone LeftFoot"); yield break; }

        float contact = 0f;
        float maxZ = float.NegativeInfinity;
        float minZ = float.PositiveInfinity;
        for (int i = 0; i < SpikeFrameStrip.Samples; i++)
        {
            float t = i / (float)SpikeFrameStrip.Samples;
            animator.Play(stateHash, 0, t);
            // OJO: hay que ESPERAR UN FRAME. Animator.Update(0) aplica el
            // pose al render pero los Transform de los huesos recien quedan
            // escritos al final del frame: leerlos en la misma llamada
            // devuelve siempre el mismo valor y el contacto sale en t=0.
            yield return null;
            float z = dagna.transform.InverseTransformPoint(lf.position).z;
            if (z > maxZ) { maxZ = z; contact = t; }
            if (z < minZ) minZ = z;
        }
        Debug.Log(string.Format("[strip] contacto del talon izquierdo en t={0:F3} (z max={1:F3}, z min={2:F3}, recorrido={3:F3})",
            contact, maxZ, minZ, maxZ - minZ));
        if (maxZ - minZ < 0.05f)
        {
            Fail("el pie no se mueve entre muestras: el Animator no esta sampleando");
            yield break;
        }

        if (footIK != null) footIK.enabled = true;

        string outDir = Path.Combine(Directory.GetParent(Application.dataPath).FullName, SpikeFrameStrip.OutDir);
        Directory.CreateDirectory(outDir);

        var camGO = new GameObject("StripCam");
        var cam = camGO.AddComponent<Camera>();
        cam.fieldOfView = SpikeFrameStrip.CamFov;
        cam.clearFlags = CameraClearFlags.Skybox;

        var rt = new RenderTexture(SpikeFrameStrip.Width, SpikeFrameStrip.Height, 24);
        var shot = new Texture2D(SpikeFrameStrip.Width, SpikeFrameStrip.Height, TextureFormat.RGB24, false);

        for (int i = 0; i < SpikeFrameStrip.Frames; i++)
        {
            float t = Mathf.Repeat(contact + i / (float)SpikeFrameStrip.Frames, 1f);
            animator.Play(stateHash, 0, t);
            // Dos frames: el primero fija el pose, el segundo deja que
            // OnAnimatorIK reaccione a el. Con uno solo el pie va atrasado.
            yield return null;
            yield return null;

            Vector3 focus = dagna.transform.position + Vector3.up * SpikeFrameStrip.LookUp;
            camGO.transform.position = focus
                + dagna.transform.right * SpikeFrameStrip.CamSide
                + Vector3.up * SpikeFrameStrip.CamUp;
            camGO.transform.rotation = Quaternion.LookRotation(focus - camGO.transform.position, Vector3.up);

            cam.targetTexture = rt;
            cam.Render();
            RenderTexture.active = rt;
            shot.ReadPixels(new Rect(0, 0, SpikeFrameStrip.Width, SpikeFrameStrip.Height), 0, 0);
            shot.Apply();
            RenderTexture.active = null;
            cam.targetTexture = null;

            string path = Path.Combine(outDir, string.Format("unity_{0:D2}.png", i));
            File.WriteAllBytes(path, shot.EncodeToPNG());
            Debug.Log(string.Format("[strip] frame {0}/{1} t={2:F3} -> {3}", i + 1, SpikeFrameStrip.Frames, t, path));
        }
    }
}
