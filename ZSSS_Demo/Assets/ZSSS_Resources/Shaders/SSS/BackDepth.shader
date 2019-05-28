Shader "ZSSS/BackDepth"
{
	Properties
	{
		/*_MainTex("Texture", 2D) = "white" {}*/
	}
		SubShader
	{
		Tags { "RenderType" = "ZSSS" }
		Cull Front
		ZWrite On
		ZTest Less

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
				float4 worldPos : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			float frag(v2f i) : SV_Target
			{
				return distance(i.worldPos.xyz, _WorldSpaceLightPos0.xyz);
			}
		ENDCG
		}
	}
}