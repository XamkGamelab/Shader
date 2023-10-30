using UnityEngine;

[ExecuteAlways]
public class BallController : MonoBehaviour
{
    [SerializeField] private Material ProximityMaterial;

    private static int PlayerPosID = Shader.PropertyToID("_PlayerPosition");
    
    void Update()
    {
        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow))
        {
            movement += Vector3.left;
        }
        if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow))
        {
            movement += Vector3.forward;
        }
        if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow))
        {
            movement += Vector3.right;
        }
        if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow))
        {
            movement += Vector3.back;
        }
        if (Input.GetKey(KeyCode.Space))
        {
            movement += Vector3.up;
        }

        if (Input.GetKey((KeyCode.C)))
        {
            movement += Vector3.down;
        }
        
        transform.Translate((Time.deltaTime * 5) * movement.normalized, Space.World);

        ProximityMaterial.SetVector(PlayerPosID, transform.position);
    }
}
