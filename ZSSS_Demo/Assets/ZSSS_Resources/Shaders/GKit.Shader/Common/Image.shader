Shader "GKit.Shader/Common/Image" {
	Properties {
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}
	SubShader {
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Stencil{
			Ref [_MaskLayer]
			Comp[_MaskComp]
			Pass [_MaskOp]
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * _Color;
			}
			ENDCG
		}
	}
}
