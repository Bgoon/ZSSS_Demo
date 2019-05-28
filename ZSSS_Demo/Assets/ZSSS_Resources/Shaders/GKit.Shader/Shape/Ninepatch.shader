Shader "GKit.Shader/Ninepatch" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeFactor ("Edge Factor", Float) = 1
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
			Comp [_MaskComp]
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _EdgeFactor;
			uniform float2 _PixelBound;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target {
				const float CenterRatio = 0.2;
				const float SideRatio = 1 - CenterRatio;

				float2 PixelBound = _PixelBound / _EdgeFactor;
				float2 sideSizeTexel = _MainTex_TexelSize.zw * SideRatio;
				float2 centerSizeUV = (PixelBound - sideSizeTexel) / PixelBound;
				float2 sideSizeUV = 1 - centerSizeUV;
				float2 remainderSizeUV = centerSizeUV + sideSizeUV * 0.5;


				float2 centerDist = abs(input.uv - 0.5);

				//조건문
				int isCenterX = centerDist.x < (centerSizeUV.x * 0.5);
				int isCenterY = centerDist.y < (centerSizeUV.y * 0.5);
				int isCenter = isCenterX || isCenterY;
				int notAllCenter = !(isCenterX && isCenterY);
				int isTop = input.uv.y > 0.5;
				int isBottom = input.uv.y < 0.5;
				int isLeft = input.uv.x < 0.5;
				int isRight = input.uv.x > 0.5;

				float2 UV2SideUV = SideRatio / sideSizeUV;
				float2 botLeftUV = input.uv * UV2SideUV;
				float2 topRightUV = (input.uv - remainderSizeUV) * UV2SideUV - SideRatio*0.5;

				float2 centerUV = 
					float2(0.5, (topRightUV.y * isTop + botLeftUV.y * isBottom) * notAllCenter) * isCenterX +
					float2((botLeftUV.x * isLeft + topRightUV.x * isRight) * notAllCenter, 0.5) * isCenterY;
				float2 sideUV =
					float2(botLeftUV.x, topRightUV.y) * (isTop && isLeft) +
					topRightUV * (isTop && isRight) +
					botLeftUV * (isBottom && isLeft) +
					float2(topRightUV.x, botLeftUV.y) * (isBottom && isRight);

				float2 uv = centerUV * isCenter + sideUV * !isCenter;
				uv.x -= uv.x > 1;
				uv.x += uv.x < 0;
				uv.y -= uv.y > 1;
				uv.y += uv.y < 0;
				fixed4 col = tex2D(_MainTex, uv);
				/*col.gb = uv;
				col.r = 0;
				col.a = 1;*/
				return col;
			}
			ENDCG
		}
	}
}
