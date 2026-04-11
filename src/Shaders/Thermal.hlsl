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
    float3 texColor = g_Texture2D.Sample(g_SamplerState, texcoord).rgb;
     
    float coeff1 = 1.5f;
    
    float3 invertColor = 1.0f - texColor;
    float val1_tmp = length(invertColor * 2.2f) / 3.0f;
    float r_0 = invertColor.r;
    float r_1 = pow(val1_tmp, 2.0f);
    float r_2 = pow(r_0, 2.0f);
    float r_3 = r_1 * coeff1;
    float g = r_1 * r_2;
    float3 col1 = float3(r_3, g, 0.0f);
    float3 col2_tmp1 = float3(r_1, g, 0.0f);
    float3 col2_tmp2 = float3(0.0f, 1.0f, 0.0f);
    float3 col2 = dot(col2_tmp1, col2_tmp2) / coeff1;
    float3 thermalColor = col1 + col2;
    
    float4 color = float4(thermalColor, 1.0f);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
