//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;
//using BigLibrary;

//#if UNITY_EDITOR
//	[ExecuteInEditMode]
//#endif
//	public class PixelBoundUpdater : MonoBehaviour {
//		private static Root Root => Root.Instance;
//		private static Screen Screen => Root.screen;

//		public bool singleBound;
//		private Material mat;
//		private new Renderer renderer;
//		void Start() {
//			renderer = GetComponent<Renderer>();
//			mat = renderer.sharedMaterial;
//		}
//		void Update() {


//#if UNITY_EDITOR
//			Vector2 pixelSize;
//			if (Root != null) {
//				pixelSize = new Vector2(
//				(renderer.bounds.size.x * Screen.info.Unit2Pixel),
//				(renderer.bounds.size.y * Screen.info.Unit2Pixel));
//			} else {
//				float unit2Pixel = Screen.info.ScreenPixelSize.x / (2f * Camera.main.orthographicSize * Camera.main.aspect);
//				pixelSize = new Vector2(
//				(renderer.bounds.size.x * unit2Pixel),
//				(renderer.bounds.size.y * unit2Pixel));
//			}
//#else
//			Vector2 pixelSize = new Vector2(
//				(renderer.bounds.size.x * Screen.info.Unit2Pixel),
//				(renderer.bounds.size.y * Screen.info.Unit2Pixel));
//#endif
//			if (singleBound) {
//				mat.SetFloat(ShaderLibrary.Shape.Property_PixelBound, pixelSize.x);
//			} else {
//				mat.SetVector(ShaderLibrary.Shape.Property_PixelBound, pixelSize);
//			}
//		}
//	}