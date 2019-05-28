using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RaySSS : MonoBehaviour
{
	public MeshFilter meshFilter;

    private void Start()
    {
        
    }
    private void Update()
    {
		DrawVertexDebug();
	}

	private void DrawVertexDebug() {
		if (meshFilter == null)
			return;

		Mesh mesh = meshFilter.sharedMesh;
		for (int vertexI = 0; vertexI < mesh.vertices.Length; vertexI += 1000) {
			Vector3 vertex = mesh.vertices[vertexI];
			vertex += transform.position;
			vertex = new Vector3(vertex.x * transform.lossyScale.x, vertex.y * transform.lossyScale.y, vertex.z * transform.lossyScale.z);
			Debug.DrawLine(vertex, vertex + mesh.normals[vertexI] * 0.1f, Color.cyan, 0.01f);
		}
	}
}
