using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZSSS : MonoBehaviour {

	public Transform lightTransform;
	public Vector2Int rtResolution;

	//Back, Front
	public Shader[] depthShaders;
	public Renderer[] debugDepthRenderers;
	private CustomRenderTexture[] depthMaps;
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

		//Create RT
		depthMaps = new CustomRenderTexture[2];
		for (int i=0; i<depthMaps.Length; ++i) {
			CustomRenderTexture rt = depthMaps[i] = CreateRT();
			debugDepthRenderers[i].material.SetTexture("_MainTex", rt);
		}
	}
	private void Update() {
		for(int i=0; i<depthMaps.Length; ++i) {
			depthCam.targetTexture = depthMaps[i];
			depthCam.SetReplacementShader(depthShaders[i], "RenderType");
			depthCam.Render();
		}

		Shader.SetGlobalMatrix("_DepthCamProj", depthCam.projectionMatrix);
		Shader.SetGlobalMatrix("_DepthCamView", depthCam.worldToCameraMatrix);
		Shader.SetGlobalTexture("_LightDistanceMap_Back", depthMaps[0]);
		Shader.SetGlobalTexture("_LightDistanceMap_Front", depthMaps[1]);
	}

	private CustomRenderTexture CreateRT() {
		return new CustomRenderTexture(rtResolution.x, rtResolution.y, RenderTextureFormat.RFloat, RenderTextureReadWrite.Linear);
	}
}
