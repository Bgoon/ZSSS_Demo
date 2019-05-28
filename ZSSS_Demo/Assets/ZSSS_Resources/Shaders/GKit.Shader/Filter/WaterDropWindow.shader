Shader "GKit.Shader/Filter/WaterDropWindow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Size ("Size", Float) = 0
		_Aspect ("Aspect", Vector) = (0, 0, 0, 0)
		_DropDistortion("Distortion", Range(-5, 5)) = 1
		_Blur("Screen Blur", Range(0, 1)) = 0
		_SampleCount("Blur Sample Count", Range(1, 64)) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		ZWrite Off
		Cull Off

		GrabPass {
			"_WaterDropWindow"
		}
        Pass
        {
            CGPROGRAM
#pragma vertex vert
#pragma fragment frag
            // make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"
#include "../Library/Global.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 grabUv : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

			sampler2D _WaterDropWindow;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Size;
			float2 _Aspect;
			float _DropDistortion;
			float _Blur;
			float _SampleCount;

			float3 WaterDropLayer(float2 uv, float time) {
				float2 elementAspect = float2(2, 1);

				//Create grid
				float2 gridUV = uv * _Size * _Aspect;
				gridUV.y = gridUV.y + time * 0.25;
				float2 gv = frac(gridUV) - 0.5;

				//Identity
				float2 id = floor(gridUV);
				float n = SampleNoise(id);
				time += n * 6.2831;

				//Animate X
				float w = uv.y * 10;
				float x = (n - 0.5) * 0.8;
				x += (0.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * 0.45;
				//Animate Y
				float y = -sin(time + sin(time + sin(time) * 0.5)) * 0.45;
				float dropShape = (gv.x - x);
				y -= dropShape * dropShape;

				//Render waterdrop
				float2 dropPos = (gv - float2(x, y)) / elementAspect;
				float drop = smoothstep(0.05, 0.03, length(dropPos));

				//Render trail
				float2 trailPos = (gv - float2(x, time * 0.25)) / elementAspect;
				trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8;
				float trail = smoothstep(0.03, 0.01, length(trailPos));
				float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
				fogTrail *= smoothstep(0.5, y, gv.y); //크기 점점 작아짐
				trail *= fogTrail;
				fogTrail *= smoothstep(0.05, 0.04, abs(dropPos.x));

				//Result
				float2 offset = drop * dropPos + trail * trailPos;

				return float3(offset, fogTrail);
			}
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabUv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = 0;
				float time = _Time.y;

				//Sample waterdrops
				float3 waterDrop = WaterDropLayer(i.uv, time);
				waterDrop += WaterDropLayer(i.uv * 1.23 + 7.54, time);
				waterDrop += WaterDropLayer(i.uv * 1.35 + 1.54, time);
				waterDrop += WaterDropLayer(i.uv * 1.57 - 7.54, time);

				//Fade using distance
				float fade = 1. - saturate(fwidth(i.uv) * 150);

				//Tuning blur
				float blur = _Blur * 7 * (1.0 - waterDrop.z * fade);
				blur *= 0.01;

				//Calculate UV
				float2 projUv = i.grabUv.xy / i.grabUv.w;
				projUv += waterDrop.xy * _DropDistortion;

				//Sample blur
				_SampleCount = floor(_SampleCount);
				float rotSpace = 360. * Deg2Rad / _SampleCount;
				float a = SampleNoise(i.uv) + rotSpace;
				float halfBlur = _Blur * 0.5;
				for (int sampleI = 0; sampleI < _SampleCount; ++sampleI) {
					float2 offset = float2(sin(a) - halfBlur, cos(a) - halfBlur) * blur;
					col += tex2D(_WaterDropWindow, projUv + offset);
					a += rotSpace;
				}
				col /= _SampleCount;
				//col *= fixed4(1, 0, 0, 1);
                return col;
            }
            ENDCG
        }
    }
}
