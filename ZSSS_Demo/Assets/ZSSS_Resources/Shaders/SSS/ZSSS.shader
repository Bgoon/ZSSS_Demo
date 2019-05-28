Shader "ZSSS/SSS"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Range ("Range", Float) = 10
		_BlurAmount("Blur Amount", Range(0, 1)) = 0.5
		_BlurSample("Blur SampleCount", Float) = 8
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
#include "../GKit.Shader/Library/Global.cginc"

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
			};

			uniform sampler2D _LightDistanceMap_Back;
			uniform sampler2D _LightDistanceMap_Front;
			uniform float4x4 _DepthCamProj;
			uniform float4x4 _DepthCamView;
			uniform sampler2D _MainTex;

			fixed4 _Color;
			fixed4 _LightColor0;
			float _Range;
			float _BlurAmount;
			float _BlurSample;

			fixed4 SampleBlur(sampler2D tex, float2 uv) {
				fixed4 color;

				_BlurSample = floor(_BlurSample);
				float rotSpace = 360. * Deg2Rad / _BlurSample;
				float a = SampleNoise(uv) + rotSpace;
				float halfBlur = _BlurAmount * 0.5;
				for (int sampleI = 0; sampleI < _BlurSample; ++sampleI) {
					float2 offset = float2(sin(a) - halfBlur, cos(a) - halfBlur) * _BlurAmount * 0.1;
					color += tex2D(tex, uv + offset);
					a += rotSpace;
				}
				color /= _BlurSample;
				return color;
			}
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = v.uv;
				return o;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				float4 cameraPos = mul(mul(_DepthCamProj, _DepthCamView), i.worldPos);
				float2 lightUv = (cameraPos.xy / cameraPos.w + 1) * 0.5;
				float distBack = SampleBlur(_LightDistanceMap_Back, lightUv).r; //tex2D(_LightDistanceMap_Back, lightUv).r;
				float distFront = SampleBlur(_LightDistanceMap_Front, lightUv).r;

				float thickness = abs(distBack - distFront) / 1.2;
				float fakeColor = 1.0 - thickness;

				/*if (thickness < 0.0) {
					return fixed4(0, 0, 0, 1);
				}*/
				fakeColor = pow(fakeColor * 0.9, 1.5);
				
				fixed4 col = fixed4(fakeColor, fakeColor, fakeColor, 1);
				col *= _Color;

				fixed3 hsv = ColorToHSV(col.rgb);
				hsv.x += fakeColor * 0.2;
				hsv.y *= 1 - pow(fakeColor, 3);
				col.rgb = HSVToColor(hsv);

				return col;

				//from light to current frag
				//float distFront = (_Range - distance(i.worldPos.xyz, _WorldSpaceLightPos0.xyz)) / _Range;
				//float distBack = (_Range - tex2D(_LightDistanceMap, i.uv).r) / _Range;
				//distBack *= 0.4;
				//distBack = pow(saturate(distBack), 3);

				//float thickness = abs(distBack - distFront);

				//fixed4 debugColor = fixed4(distBack, distBack, distBack, 1);
				//debugColor *= _Color;
				//return debugColor;
			}
		ENDCG
		}
    }

    FallBack "Diffuse"
}
