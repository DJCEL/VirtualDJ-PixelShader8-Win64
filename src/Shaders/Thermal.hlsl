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

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float2 texcoord = input.TexCoord;
    float3 inColor = g_Texture2D.Sample(g_SamplerState, texcoord).rgb;
    
    float3 invertColor = float3(1.0f, 1.0f, 1.0f) - inColor;
    float len = pow((length(invertColor * 2.2f)) / 3.0f, 2.0f);
    float3 col = float3(len, len * pow((1.0f - inColor.r), 2.0f), 0.0f);
    float3 thermalColor= float3(len * 1.5f, len * pow((1.0f - inColor.r), 2.0f), 0.0f) + dot(col, float3(0.0f, 1.0f, 0.0f)) / 1.5f;
    
    float4 color = float4(thermalColor, 1.0f);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
