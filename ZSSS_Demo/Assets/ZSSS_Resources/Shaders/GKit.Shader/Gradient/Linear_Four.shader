Shader "GKit.Shader/Gradient/Linear_Four"
{
	Properties {
		_ColorA("Color A", Color) = (1, 1, 1, 1)
		_ColorB("Color B", Color) = (1, 1, 1, 1)
		_ColorC("Color C", Color) = (1, 1, 1, 1)
		_ColorD("Color D", Color) = (1, 1, 1, 1)
		_PointA("Point A", Range(0, 1)) = 0
		_PointB("Point B", Range(0, 1)) = 0.333
		_PointC("Point C", Range(0, 1)) = 0.666
		_PointD("Point D", Range(0, 1)) = 1
		
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

			fixed4 _ColorA, _ColorB, _ColorC, _ColorD;
			float _PointA, _PointB, _PointC, _PointD;

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
			fixed4 frag(v2f input) : COLOR {
				float uvY = input.uv.y;

				fixed4 colorAB = lerp(_ColorA, _ColorB, saturate(RemapUV(uvY, _PointA, _PointB)));
				fixed4 colorBC = lerp(_ColorB, _ColorC, RemapUV(uvY, _PointB, _PointC));
				fixed4 colorCD = lerp(_ColorC, _ColorD, saturate(RemapUV(uvY, _PointC, _PointD))
				);

				int isAB = uvY < _PointB;
				int isBC = (uvY >= _PointB) * (uvY < _PointC);
				int isCD = uvY >= _PointC;

				return colorAB * isAB + colorBC * isBC + colorCD * isCD;
			}
			ENDCG
		}
	}
}