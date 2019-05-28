Shader "GKit.Shader/Shape/Innerline" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_Width("Line Width", Float) = 1

		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}

	SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Stencil{
			Ref [_MaskLayer]
			Comp [_MaskComp]
			Pass [_MaskOp]
		}

		Pass{
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			fixed4 _Color;
			float _Width;
			uniform float2 _PixelBound;

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f input) : COLOR{
				float2 Pixel2UV = 1 / (_PixelBound);
				float2 centerDist = abs(input.uv - 0.5);

				float2 outlineThresold = 0.5-Pixel2UV * _Width;
				fixed alpha = centerDist.x >= outlineThresold.x || centerDist.y >= outlineThresold.y;
				return fixed4(_Color.rgb, alpha * _Color.a);
			}
		ENDCG
		}
	}

}
