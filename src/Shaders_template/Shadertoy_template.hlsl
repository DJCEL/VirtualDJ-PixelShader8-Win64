////////////////////////////////
// File: Shadertoy_template.hlsl
////////////////////////////////

//--------------------------------------------------------------------------------------
// Textures and Samplers
//--------------------------------------------------------------------------------------
Texture2D g_Texture2D : register(t0);
SamplerState g_SamplerState : register(s0);
//--------------------------------------------------------------------------------------
// Constant Buffer
//--------------------------------------------------------------------------------------
cbuffer PS_CONSTANTBUFFER : register(b0)
{
    float g_FX_Time;
    float g_FX_Width;
    float g_FX_Height;
    float g_FX_params_on;
    float g_FX_param1;
    float g_FX_param2;
    float g_FX_param3;
    float g_FX_param4;
    float g_FX_param5;
};
//--------------------------------------------------------------------------------------
// Input structure
//--------------------------------------------------------------------------------------
struct PS_INPUT
{
    float4 Position : SV_Position;
    float4 Color : COLOR0;
    float2 TexCoord : TEXCOORD0;
};
//--------------------------------------------------------------------------------------
// Output structure
//--------------------------------------------------------------------------------------
struct PS_OUTPUT
{
    float4 Color : SV_TARGET;
};
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
#define iChannel0 g_SamplerState
#define texture g_Texture2D.Sample
vec3 iResolution = float3(g_FX_Width, g_FX_Height, 0.0f);
float iTime = g_FX_Time;
//--------------------------------------------------------------------------------------
// Shadertoy - mainImage()
//--------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col = texture(iChannel0, uv).xyz;
    
    col.g = 0;
    col.b = 0;
    
    fragColor = vec4(col, 1.0f);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float2 texcoord = input.TexCoord;
    
    float2 fragCoord = texcoord * iResolution.xy;
    float4 fragColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    mainImage(fragColor, fragCoord);
    
    PS_OUTPUT output;
    output.Color = fragColor;
    output.Color *= input.Color;
    return output;
}



