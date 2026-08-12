using UnityEngine;

// Spike ADR-003: reemplazo minimo de Cinemachine (incompatible con esta
// build beta de Unity) -- solo para poder ver la escena en Play, no es
// parte de lo que estamos comparando.
public class SpikeFollowCamera : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Vector3 offset = new Vector3(0f, 2.2f, -4.5f);
    [SerializeField] private float followSmooth = 6f;
    [SerializeField] private float lookSmooth = 8f;

    private void LateUpdate()
    {
        if (target == null) return;

        Vector3 desiredPos = target.position + target.TransformDirection(offset);
        transform.position = Vector3.Lerp(transform.position, desiredPos, followSmooth * Time.deltaTime);

        Vector3 lookPoint = target.position + Vector3.up * 1.3f;
        Quaternion desiredRot = Quaternion.LookRotation(lookPoint - transform.position, Vector3.up);
        transform.rotation = Quaternion.Slerp(transform.rotation, desiredRot, lookSmooth * Time.deltaTime);
    }
}
