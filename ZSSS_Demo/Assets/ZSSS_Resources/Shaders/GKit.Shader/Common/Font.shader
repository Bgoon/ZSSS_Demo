Shader "GKit.Shader/Common/Font" {
	Properties {
		[PerRendererData] _MainTex ("Font Texture", 2D) = "white" {}
		_Color ("Font Color", Color) = (1, 1, 1, 1)
		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}
	SubShader {
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector"="True" }

		Cull Off
		ZTest LEqual
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Stencil{
			Ref[_MaskLayer]
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
				fixed4 color : COLOR;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 color = fixed4(i.color.rgb, tex2D(_MainTex, i.uv).a * i.color.a);

				clip(color.a-0.2);
				return color * _Color;
			}
			ENDCG
		}
	}
}
