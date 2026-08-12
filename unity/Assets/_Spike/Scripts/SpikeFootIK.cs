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
