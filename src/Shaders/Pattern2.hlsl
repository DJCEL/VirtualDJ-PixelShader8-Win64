////////////////////////////////
// File: Pattern2.hlsl
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
    float g_FX_SongPosBeats;
    float g_FX_Width;
    float g_FX_Height;
    float g_FX_Beats_on;
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
//--------------------------------------------------------------------------------------
// Additional functions
//--------------------------------------------------------------------------------------
float ParamAdjust(float value, float ValMin, float ValMax)
{
    return ValMin + value * (ValMax - ValMin);
}
//--------------------------------------------------------------------------------------
float random(in float x)
{
    return frac(sin(x) * 43758.5453);
}
//--------------------------------------------------------------------------------------
float random(in float2 st)
{
    return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float time = (g_FX_Beats_on == 1.0f) ? g_FX_SongPosBeats : g_FX_Time;
    
    float2 texcoord = input.TexCoord;
    float4 texcolor = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    float3 colormask = float3(0.0, 0.0, 0.0);
    float2 st = texcoord;
    st.x *= g_FX_Width / g_FX_Height;
    float2 blocks_st = floor(st * 6.0);
    float t = time * .8 + random(blocks_st);
    float time_i = floor(t);
    float time_f = frac(t);
    colormask.rgb += step(0.9, random(blocks_st + time_i)) * (1.0 - time_f);
    float4 mask = float4(colormask.r, colormask.g, colormask.b, 1.0f);
    
    float4 color = texcolor * mask;
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
