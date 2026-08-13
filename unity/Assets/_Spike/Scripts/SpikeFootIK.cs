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

            // OFFSET VERTICAL, a proposito -- y no es el error de coseno que
            // parece.
            //
            // Se probo desplazar a lo largo de la normal del terreno (que es
            // lo que hace el lado Godot y lo que pediria la fisica si
            // `footOffsetY` fuera la altura del tobillo sobre la planta). La
            // rampa EMPEORO: +0.031 -> +0.055 m de flotacion. Medido, no
            // supuesto.
            //
            // La razon: `footOffsetY` calibrado da 0.21 m, y un tobillo real
            // esta a 0.08-0.10. O sea que este numero NO es una altura de
            // tobillo: es un factor que absorbe la geometria tobillo->punta
            // de la bota, que es lo que marca el punto mas bajo de la
            // silueta. Un factor de correccion asi no tiene una direccion
            // fisica que respetar, y girarlo con la pendiente solo lo
            // desalinea. El argumento del coseno vale para una altura real;
            // no vale para un fudge.
            Vector3 targetPos = hit.point + Vector3.up * footOffsetY;
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
