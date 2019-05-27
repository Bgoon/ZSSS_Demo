Shader "Custom/ZSSS"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_Shininess ("Shiness", Float) = 10
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1)
		_Range ("Range", Float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="ZSSS" }
		Cull Back

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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};

			uniform sampler2D _LightDistanceMap;
			fixed4 _Color;
			fixed4 _LightColor0;
			float _Shininess;
			float _Range;
			fixed4 _SpecColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 normalDirection = normalize(i.normalDir);

				float3 viewDirection = normalize(
				   _WorldSpaceCameraPos - i.worldPos.xyz);
				float3 lightDirection;
				float attenuation;

				if (0.0 == _WorldSpaceLightPos0.w) // directional light?
				{
				   attenuation = 1.0; // no attenuation
				   lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else // point or spot light
				{
				   float3 vertexToLightSource =
					  _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
				   float distance = length(vertexToLightSource);
				   attenuation = 1.0 / distance; // linear attenuation 
				   lightDirection = normalize(vertexToLightSource);
				}

				float3 ambientLighting =
				   UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

				float3 diffuseReflection =
				   attenuation * _LightColor0.rgb * _Color.rgb
				   * max(0.0, dot(normalDirection, lightDirection));

				float3 specularReflection;
				if (dot(normalDirection, lightDirection) < 0.0)
					// light source on the wrong side?
				 {
					specularReflection = float3(0.0, 0.0, 0.0);
					// no specular reflection
				}
				else // light source on the right side
				{
					specularReflection = attenuation * _LightColor0.rgb
					* _SpecColor.rgb * pow(max(0.0, dot(
					reflect(-lightDirection, normalDirection),
					viewDirection)), _Shininess);
				}

				//from light to current frag
				float distFront = (_Range - distance(i.worldPos.xyz, _WorldSpaceLightPos0.xyz)) / _Range;
				float distBack = (_Range - tex2D(_LightDistanceMap, i.uv).r) / _Range;
				distBack *= 0.4;
				distBack = pow(saturate(distBack), 3);

				//return fixed4(distBack, 0, 0, 1);
				float thickness = abs(distBack - distFront);
				thickness = saturate(distFront - distBack);
				thickness = pow(thickness, 5);
				//return fixed4(thickness, thickness, thickness, 1);

				fixed4 debugColor = fixed4(thickness, thickness, thickness, 1);
				debugColor *= _Color;
				debugColor.rgb += ambientLighting * 0.3 + diffuseReflection * max(0.05 - thickness, 0) + specularReflection;
				return debugColor;

				if (thickness < 0)
					return fixed4(-thickness, 0, 0, 1);
				else
					return fixed4(0, thickness, 0, 1);

				return fixed4(thickness, thickness, thickness, 1);
			}
		ENDCG
		}
    }

    FallBack "Diffuse"
}
