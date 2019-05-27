// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/PreZSSS"
{
	Properties
	{
		/*_MainTex("Texture", 2D) = "white" {}*/
	}
		SubShader
	{
		Tags { "RenderType" = "ZSSS" }
		Cull Off
		ZWrite Off
		ZTest Off

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
				float4 worldPos : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				float2 uv = v.uv - 0.5;// *2 - 2;
				uv *= float2(2., -2.);
				o.vertex = float4(uv, 0, 1);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			float frag(v2f i) : SV_Target
			{
				return distance(i.worldPos.xyz, _WorldSpaceLightPos0.xyz) * 0.3;
			}
		ENDCG
		}
	}
}