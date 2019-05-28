using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer), typeof(TextMesh))]
public class FontTextureUpdater : MonoBehaviour {

	private TextMesh textMesh;
	private MeshRenderer meshRenderer;
	public Font font;
	
	private void Start() {
		textMesh = GetComponent<TextMesh>();
		meshRenderer = GetComponent<MeshRenderer>();
	}
	private void Update () {
		if (textMesh.font != font) {
			textMesh.font = font;
			if (font != null) {
				meshRenderer.sharedMaterial.SetTexture("_MainTex", font.material.mainTexture);
			}
		}
	}
}
