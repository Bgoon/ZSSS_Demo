Shader "GKit.Shader/Gradient/Linear_Two"
{
	Properties {
		_ColorA("Color A", Color) = (1, 1, 1, 1)
		_ColorB("Color B", Color) = (1, 1, 1, 1)
		_PointA("Point A", Range(0, 1)) = 0
		_PointB("Point B", Range(0, 1)) = 1
		
		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}

	SubShader {
		Stencil{
			Ref[_MaskLayer]
			Comp [_MaskComp]
			Pass [_MaskOp]
		}

		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct vertexIn {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			fixed4 _ColorA, _ColorB;
			float _PointA, _PointB;

			float RemapUV(float value, float start, float end) {
				float range = end - start;
				range = max(0.00001, range);
				return (value - start) / range;
			}
			v2f vert(vertexIn input) {
				v2f output;

				output.pos = UnityObjectToClipPos(input.pos);
				output.uv = input.uv;

				return output;
			}

			fixed4 frag(v2f input) : COLOR{
				float uvY = input.uv.y;

				fixed4 colorAB = lerp(_ColorA, _ColorB, saturate(RemapUV(uvY, _PointA, _PointB)));

				return colorAB;
			}
			ENDCG
		}
	}
}