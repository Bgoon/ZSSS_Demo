using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZSSS : MonoBehaviour {

	public Shader replacementShader;
	public Renderer debugDepthRenderer;
	public Transform lightTransform;
	private CustomRenderTexture depthMap;
	private Camera depthCam;

	private void Start() {
		GameObject depthCamObj = new GameObject("DepthCamera");
		depthCamObj.transform.parent = lightTransform;
		depthCam = depthCamObj.AddComponent<Camera>();
		depthCam.orthographic = true;
		depthCam.orthographicSize = 7f;

		depthCam.transform.localPosition = Vector3.zero;
		depthCam.transform.localEulerAngles = Vector3.zero;

		//depthCam = Camera.main;
		depthCam.clearFlags = CameraClearFlags.Color;
		depthCam.enabled = false;
		depthCam.farClipPlane = 40f;
		depthCam.SetReplacementShader(replacementShader, "RenderType");

		//Create RT
		depthMap = new CustomRenderTexture(512, 512, RenderTextureFormat.RFloat, RenderTextureReadWrite.Linear);
		if(debugDepthRenderer != null) {
			debugDepthRenderer.material.SetTexture("_MainTex", depthMap);
		}
		depthCam.targetTexture = depthMap;
	}

	private void Update() {
		depthCam.Render();
		Shader.SetGlobalMatrix("_DepthCamProj", depthCam.projectionMatrix);
		Shader.SetGlobalMatrix("_DepthCamView", depthCam.worldToCameraMatrix);
		Shader.SetGlobalTexture("_LightDistanceMap", depthMap);
	}
	//private void OnRenderImage(RenderTexture src, RenderTexture dst) {
	//	Graphics.Blit(src, )
	//}
}
