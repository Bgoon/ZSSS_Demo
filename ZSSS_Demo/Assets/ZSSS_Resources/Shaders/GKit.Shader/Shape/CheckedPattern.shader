Shader "GKit.Shader/Shape/CheckedPattern" {
	Properties {
		_PatternSize("Pattern Size", Float) = 1
		_ColorA("Color A", Color) = (1, 1, 1, 1)
		_ColorB("Color B", Color) = (0, 0, 0, 1)

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
			#pragma target 3.0
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

			uniform float2 _PixelBound;
			float _PatternSize;
			fixed4 _ColorA;
			fixed4 _ColorB;

			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				i.uv = (int2)(i.uv * _PatternSize * _PixelBound * 0.1);
				int isPattern1 = ((i.uv.x % 2) == 0) ^ ((i.uv.y % 2) == 0);

				fixed4 col = _ColorA * isPattern1 + _ColorB * (1-isPattern1);
				return col;
			}
			ENDCG
		}
	}
}
