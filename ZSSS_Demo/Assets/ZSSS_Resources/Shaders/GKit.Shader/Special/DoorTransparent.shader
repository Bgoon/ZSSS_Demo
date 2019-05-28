Shader "GKit.Shader/Special/DoorTransparent"
{
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_Cutoff("Texture Cutoff", Range(0, 1)) = 0.5
		_Alpha("Alpha cutoff", Range(0, 1)) = 1
		
		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "False" "RenderType" = "Transparent" }
		Cull Off

		Stencil{
			Ref [_MaskLayer]
			Comp[_MaskComp]
			Pass [_MaskOp]
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutoff;
			float _Alpha;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				float4x4 thresholdMatrix =
				{ 1.0 / 17.0,  
					9.0 / 17.0,  
					3.0 / 17.0, 
					11.0 / 17.0,
					13.0 / 17.0, 
					5.0 / 17.0, 
					15.0 / 17.0,  
					7.0 / 17.0,
					4.0 / 17.0,
					12.0 / 17.0, 
					2.0 / 17.0, 
					10.0 / 17.0,
					16.0 / 17.0, 
					8.0 / 17.0, 
					14.0 / 17.0, 
					6.0 / 17.0,
				};
				float4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
				float2 pixelPos = i.screenPos.xy / i.screenPos.w * _ScreenParams.xy;
				clip((_Alpha - thresholdMatrix[fmod(pixelPos.x, 4)] * _RowAccess[fmod(pixelPos.y, 4)]) - (col.a < _Cutoff));
				return col;
			}
			ENDCG
		}
	}
}
