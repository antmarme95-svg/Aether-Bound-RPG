using UnityEngine;

// Spike ADR-003: foot IK stock de Unity (Animator.SetIKPosition/Rotation)
// sobre un Humanoid rig importado del Asset Store, sin solver custom.
// Pregunta que responde: ¿alcanza esto para que el pie se plante bien
// en una pendiente, o hace falta construir algo a mano como en Godot?
[RequireComponent(typeof(Animator))]
public class SpikeFootIK : MonoBehaviour
{
    [SerializeField] private float raycastDistance = 0.5f;
    [SerializeField] private float footOffsetY = 0.05f;
    [SerializeField] private LayerMask groundLayers = ~0;
    [SerializeField] private bool enableIK = true;

    private Animator animator;

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    private void OnAnimatorIK(int layerIndex)
    {
        if (!enableIK || animator == null) return;

        PlaceFoot(AvatarIKGoal.LeftFoot);
        PlaceFoot(AvatarIKGoal.RightFoot);
    }

    private void PlaceFoot(AvatarIKGoal foot)
    {
        Vector3 footPos = animator.GetIKPosition(foot);
        Vector3 rayOrigin = footPos + Vector3.up * raycastDistance;

        if (Physics.Raycast(rayOrigin, Vector3.down, out RaycastHit hit, raycastDistance * 2f, groundLayers))
        {
            animator.SetIKPositionWeight(foot, 1f);
            animator.SetIKRotationWeight(foot, 1f);

            // El offset va a lo largo de la NORMAL del terreno, no de
            // Vector3.up: el tobillo se separa de la superficie
            // perpendicularmente a ella, no en vertical. Con `up`, en
            // pendiente el objetivo se queda corto por un factor
            // cos(angulo). Es el mismo criterio que usa el lado Godot
            // (godot/scripts/foot_ik.gd).
            //
            // ⚠️ CAMBIO POR PRINCIPIO, NO VALIDADO POR MEDICION. El
            // instrumento que deberia confirmarlo
            // (Editor/SpikeFootIKBenchmark.cs) tiene el encuadre mal: la
            // captura muestra al personaje rotado y cortado, asi que sus
            // numeros de penetracion no son confiables todavia. No tomar
            // como bueno el "antes/despues" hasta arreglar el encuadre.
            Vector3 targetPos = hit.point + hit.normal * footOffsetY;
            animator.SetIKPosition(foot, targetPos);

            Quaternion footRotation = Quaternion.FromToRotation(Vector3.up, hit.normal) * animator.GetIKRotation(foot);
            animator.SetIKRotation(foot, footRotation);
        }
        else
        {
            animator.SetIKPositionWeight(foot, 0f);
            animator.SetIKRotationWeight(foot, 0f);
        }
    }
}
