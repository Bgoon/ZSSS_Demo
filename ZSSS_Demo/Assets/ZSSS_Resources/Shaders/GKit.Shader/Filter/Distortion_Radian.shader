Shader "GKit.Shader/Filter/Distortion_Radian" { 
	Properties{
		_MainTex("Albedo", 2D) = "white" {}
		_Size("Distortion Size", Range(0, 0.1)) = 0.05

		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}
	SubShader{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		zwrite off
		cull off

		GrabPass{
			"_ScreenTex"
		}
		Stencil{
			Ref[_MaskLayer]
			Comp [_MaskComp]
			Pass [_MaskOp]
		}
		Pass{
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
				float4 screenPos : TEXCOORD1;
			};

			sampler2D _ScreenTex;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float2 screenUV = i.screenPos.xy / i.screenPos.w;
				
				fixed4 distMap = tex2D(_MainTex, i.uv);
				float2 normal = normalize(float2(i.uv.x, 1-i.uv.y) - 0.5);
				screenUV += normal * (distMap.x * _Size);

				fixed4 col = tex2D(_ScreenTex, screenUV);
				return col;
			}
			ENDCG
		}
	}
}
