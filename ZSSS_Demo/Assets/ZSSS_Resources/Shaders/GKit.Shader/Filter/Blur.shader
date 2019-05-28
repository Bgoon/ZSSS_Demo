Shader "GKit.Shader/Filter/Blur" {
	Properties{
		_Size("Blur Size", Range(0, 50)) = 1
		_Alpha("Alpha", Range(0, 1)) = 1
		_Color("Over Color", Color) = (0, 0, 0, 0)
		
		_MaskLayer("Mask Layer", Int) = 0
		_MaskComp("Mask Composition", Int) = 0
		_MaskOp("Mask Operation", Int) = 0
	}
	Category{
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		ZTest Off
		ZWrite Off

		SubShader{
			Stencil{
				Ref[_MaskLayer]
				Comp[_MaskComp]
				Pass [_MaskOp]
			}
			GrabPass{
				"_HBlur"
			}
			Pass{
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"
#include "../Library/Global.cginc"
#pragma target 4.0

				struct appdata_t {
					float4 vertex : POSITION;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float4 uvgrab : TEXCOORD0;
				};

				sampler2D _HBlur;
				float4 _HBlur_TexelSize;
				float _Size;
				float _Alpha;
				fixed4 _Color;

				v2f vert(appdata_t v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uvgrab = ComputeGrabScreenPos(o.pos);

					return o;
				}
				fixed4 frag(v2f i) : COLOR{
					fixed4 screen = tex2Dproj(_HBlur, i.uvgrab);
					fixed4 sum = fixed4(0,0,0,0);

#define GRABPIXELX(weight,kernelx) tex2Dproj( _HBlur, UNITY_PROJ_COORD(float4(i.uvgrab.x + _HBlur_TexelSize.x * kernelx * _Size, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight

					sum += GRABPIXELX(0.05, -4.0);
					sum += GRABPIXELX(0.09, -3.0);
					sum += GRABPIXELX(0.12, -2.0);
					sum += GRABPIXELX(0.15, -1.0);
					sum += GRABPIXELX(0.18,  0.0);
					sum += GRABPIXELX(0.15, +1.0);
					sum += GRABPIXELX(0.12, +2.0);
					sum += GRABPIXELX(0.09, +3.0);
					sum += GRABPIXELX(0.05, +4.0);

					fixed4 blurredColor = saturate(sum);
					blurredColor.a = _Alpha;

					return AlphaBlend(screen, blurredColor);
				}
				ENDCG
			}
			GrabPass{
				"_VBlur"
			}
			Pass{
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"
#include "../Library/Global.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
				};
				struct v2f {
					float4 pos : SV_POSITION;
					float4 uvgrab : TEXCOORD0;
				};

				sampler2D _VBlur;
				float4 _VBlur_TexelSize;
				float _Size;
				float _Alpha;
				fixed4 _Color;

				v2f vert(appdata_t v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uvgrab = ComputeGrabScreenPos(o.pos);

					return o;
				}


				fixed4 frag(v2f i) : COLOR{
					fixed4 screen = tex2Dproj(_VBlur, i.uvgrab);
					fixed4 sum = fixed4(0,0,0,0);
#define GRABPIXELY(weight,kernely) tex2Dproj( _VBlur, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _VBlur_TexelSize.y * kernely * _Size, i.uvgrab.z, i.uvgrab.w))) * weight

					sum += GRABPIXELY(0.05, -4.0);
					sum += GRABPIXELY(0.09, -3.0);
					sum += GRABPIXELY(0.12, -2.0);
					sum += GRABPIXELY(0.15, -1.0);
					sum += GRABPIXELY(0.18,  0.0);
					sum += GRABPIXELY(0.15, +1.0);
					sum += GRABPIXELY(0.12, +2.0);
					sum += GRABPIXELY(0.09, +3.0);
					sum += GRABPIXELY(0.05, +4.0);

					fixed4 blurredColor = saturate(sum);
					fixed4 result = AlphaBlend(blurredColor, _Color);
					result.a *= _Alpha;
					return AlphaBlend(screen, result);
				}
				ENDCG
			}
		}
	}
}