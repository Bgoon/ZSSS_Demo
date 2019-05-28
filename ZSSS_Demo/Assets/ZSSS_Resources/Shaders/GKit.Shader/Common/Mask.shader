Shader "GKit.Shader/Common/Mask" {
	Properties{
		_WriteMaskLayer("WriteMask Layer", Int) = 0
	}
	SubShader{
		Tags{ "Queue" = "Geometry"}
		Stencil{
			Ref [_WriteMaskLayer]
			Comp always
			Pass replace
		}
		//Blend SrcAlpha OneMinusSrcAlpha
		ZTest LEqual
		ZWrite True
		ColorMask 0
		Pass{
			/*CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f {
				float4 vertex : POSITION;
			};

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : COLOR{
				return fixed4(0,0,0,0);
			}
			ENDCG*/
		}
	}
}