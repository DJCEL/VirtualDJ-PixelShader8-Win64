////////////////////////////////
// File: Thermal2.hlsl
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
float greyScale(float3 RGB)
{
    return 0.29 * RGB.r + 0.60 * RGB.g + 0.11;
}
//--------------------------------------------------------------------------------------
float3 heatMap(float greyValue)
{
    float3 heat;
    heat.r = smoothstep(0.5, 0.8, greyValue);
    if (greyValue >= 0.8333)
    {
        heat.r *= (1.1 - greyValue) * 5.0;
    }
    if (greyValue > 0.6)
    {
        heat.g = smoothstep(1.0, 0.7, greyValue);
    }
    else
    {
        heat.g = smoothstep(0.0, 0.7, greyValue);
    }
    heat.b = smoothstep(1.0, 0.0, greyValue);
    if (greyValue <= 0.3333)
    {
        heat.b *= greyValue / 0.3;
    }
    return heat;
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float strength = 100.0f;
    if (g_FX_params_on)
    {
        strength = ParamAdjust(g_FX_param1, 0.20f, 200.0f);
    }
    
    float2 texcoord = input.TexCoord;
    float4 texColor = g_Texture2D.Sample(g_SamplerState, texcoord);
     
    float greyValue = greyScale(texColor.rgb);
    float3 h = heatMap(greyValue * (strength / 100.0));
    float4 color = float4(h.r, h.g, h.b, texColor.a);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
