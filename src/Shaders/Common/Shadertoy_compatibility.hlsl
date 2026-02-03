//--------------------------------------
// Shadertoy compatibility
//--------------------------------------
#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mix lerp
#define fract frac
#define mod fmod
vec3 iResolution = float3(float(iResolutionWidth), float(iResolutionHeight), 0.0f);
#define fragCoord (input.TexCoord * iResolution.xy)
#define fragColor (PS_OUTPUT output; output.Color)
#define iChannel0 g_SamplerState
#define texture g_Texture2D.Sample
