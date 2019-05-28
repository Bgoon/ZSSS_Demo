// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Unlit shader. Simplest possible colored shader.
// - no lighting
// - no lightmap support
// - no texture

Shader "GKit.Shader/Shape/RoundedBox" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_Radius("Vertex Radius", Float) = 5
		
		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}

	SubShader{
		Tags{ "RenderType"="Transparent" "Queue"="Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Stencil{
			Ref[_MaskLayer]
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
			float _Radius;
			uniform float2 _PixelBound;

			v2f vert(appdata v) {
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}

			fixed4 frag(v2f input) : COLOR {
				float2 Pixel2UV = 1 / _PixelBound;
				//단위 변환
				float ratio = _PixelBound.x * Pixel2UV.y;

				float alphaArray[2] = { 0, 1 };

				//반지름
				float2 radius = float2(_Radius / ratio, _Radius) * Pixel2UV.y;
				//거리
				float2 fromCenter = abs(input.uv - 0.5) + 0.5;

				//사각형
				float2 rectArea = 1 - radius;

				//원
				float2 circleDist = (fromCenter + radius - 1);
				circleDist = float2(circleDist.x * ratio, circleDist.y) * _PixelBound.y;
				float circleValue = _Radius * _Radius - (circleDist.x * circleDist.x + circleDist.y * circleDist.y);
				//AA
				const float AAValue = 3*_Radius;
				circleValue = saturate((circleValue+AAValue*0.5) * (1/AAValue));

				//결과
				fixed alpha = saturate(alphaArray[fromCenter.x <= rectArea.x || fromCenter.y <= rectArea.y]
					+ circleValue);
				return fixed4(_Color.rgb, _Color.a * alpha);
			}
			ENDCG
		}
	}
}