using UnityEngine;

// Spike ADR-003: mueve a Dagna hacia un punto fijo para poder observar
// el ciclo de caminata + foot IK en la pendiente sin necesitar IA real.
// No es el companion final -- es solo el driver minimo para el spike.
[RequireComponent(typeof(CharacterController))]
[RequireComponent(typeof(Animator))]
public class SpikeCompanionWalk : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private float walkSpeed = 1.5f;
    [SerializeField] private float stopDistance = 1.0f;
    [SerializeField] private float gravity = -15f;

    private CharacterController controller;
    private Animator animator;
    private float verticalVelocity;

    private static readonly int SpeedParam = Animator.StringToHash("Speed");
    private static readonly int MotionSpeedParam = Animator.StringToHash("MotionSpeed");
    private static readonly int GroundedParam = Animator.StringToHash("Grounded");

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();
    }

    private void Update()
    {
        float speed = 0f;

        if (target != null)
        {
            Vector3 toTarget = target.position - transform.position;
            toTarget.y = 0f;
            float distance = toTarget.magnitude;

            if (distance > stopDistance)
            {
                Vector3 dir = toTarget.normalized;
                transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(dir), Time.deltaTime * 5f);
                speed = walkSpeed;
            }
        }

        if (controller.isGrounded)
        {
            verticalVelocity = -2f;
        }
        else
        {
            verticalVelocity += gravity * Time.deltaTime;
            verticalVelocity = Mathf.Max(verticalVelocity, -20f);
        }

        Vector3 motion = transform.forward * speed + Vector3.up * verticalVelocity;
        controller.Move(motion * Time.deltaTime);

        if (transform.position.y < -20f)
        {
            controller.enabled = false;
            transform.position = new Vector3(transform.position.x, 0.1f, transform.position.z);
            verticalVelocity = 0f;
            controller.enabled = true;
        }

        animator.SetFloat(SpeedParam, speed);
        animator.SetFloat(MotionSpeedParam, 1f);
        animator.SetBool(GroundedParam, controller.isGrounded);
    }

    // Starter Assets' Walk/Run clips fire these via AnimationEvent; without
    // a receiver Unity logs an error every step. No audio wired up yet for
    // Dagna, so these are intentionally empty.
    private void OnFootstep(AnimationEvent animationEvent) { }
    private void OnLand(AnimationEvent animationEvent) { }
}
