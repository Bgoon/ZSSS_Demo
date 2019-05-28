#ifndef Global_INCLUDED
#define Global_INCLUDED

#define PI 3.14159274
#define Deg2Rad 0.0174532924
#define Rad2Deg 57.29578

inline fixed4 AlphaBlend(fixed4 dst, fixed4 src) {
	fixed dstFactor = dst.a * (1 - src.a);
	fixed resultAlpha = saturate(dstFactor + src.a);
	fixed srcFactor = src.a / resultAlpha;
	dst = fixed4(dst.rgb * dstFactor + src.rgb * srcFactor, resultAlpha);
	return saturate(dst);
}
inline float2 PolarCoordinate(float2 uv) {
	float2 delta = uv - 0.5;
	float radius = length(delta) * 2;
	float angle = atan2(delta.y, delta.x) * 1.0 / 6.28;
	return float2(radius, angle);
}
inline float SampleNoise(float2 uv) {
	float2 p = frac(uv * float2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return frac(p.x * p.y);
}
fixed3 ColorToHSV(fixed3 color) {
	fixed4 K = fixed4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	fixed4 p = lerp(fixed4(color.bg, K.wz), fixed4(color.gb, K.xy), step(color.b, color.g));
	fixed4 q = lerp(fixed4(p.xyw, color.r), fixed4(color.r, p.yzx), step(p.x, color.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return fixed3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
fixed3 HSVToColor(fixed3 hsv) {
	fixed4 K = fixed4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	fixed3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}
fixed3 HSVToColorLegacy(float h, float s, float v) {
	h = clamp(h, 0, 360);
	s = clamp(s, 0, 1);
	v = clamp(v, 0, 1);

	int hi = floor(h / 60) % 6;
	fixed f = h / 60 - floor(h / 60);
	fixed p = v * (1 - s);
	fixed q = v * (1 - f * s);
	fixed t = v * (1 - (1 - f) * s);

	fixed3 results[6] = {
		fixed3(v, t, p),
		fixed3(q, v, p),
		fixed3(p, v, t),
		fixed3(p, q, v),
		fixed3(t, p, v),
		fixed3(v, p, q)
	};

	return results[hi];
}
#endif