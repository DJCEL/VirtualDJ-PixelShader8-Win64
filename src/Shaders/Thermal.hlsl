////////////////////////////////
// File: Thermal.hlsl
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
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float2 texcoord = input.TexCoord;
    float3 inColor = g_Texture2D.Sample(g_SamplerState, texcoord).rgb;
    
    float3 invertColor = 1.0f - inColor;
    float val1_tmp = length(invertColor * 2.2f) / 3.0f;
    float val2_tmp = 1.0f - inColor.r;
    float val1 = pow(val1_tmp, 2.0f);
    float val2 = pow(val2_tmp, 2.0f);
    float val3 = val1 * val2;
    float3 col1 = float3(val1 * 1.5f, val3, 0.0f);
    float3 col2 = float3(val1, val3, 0.0f);
    float3 col3 = float3(0.0f, 1.0f, 0.0f);
    float3 col4 = dot(col2, col3) / 1.5f;
    float3 thermalColor = col1 + col4;
    
    float4 color = float4(thermalColor, 1.0f);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
