////////////////////////////////
// File: Sharpen1.hlsl
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
    float Amount = 3.0f;

    if (g_FX_params_on == 1.0f)
    {
        Amount = ParamAdjust(g_FX_param1, 0.0f, 20.0f);
    }
        
    float2 texcoord = input.TexCoord;
    
    float2 u_textureSize = float2(g_FX_Width, g_FX_Height);
    float2 texel = 1.0f / u_textureSize;
    
    // Unsharp Mask
    float2 offset_center = float2(0.0f, 0.0f);
    float2 offset_left = float2(-texel.x, 0.0f);
    float2 offset_right = float2(texel.x, 0.0f);
    float2 offset_top = float2(0.0f, -texel.y);
    float2 offset_bottom = float2(0.0f, texel.y);
    
    float3 center = g_Texture2D.Sample(g_SamplerState, texcoord + offset_center).rgb;
    float3 left = g_Texture2D.Sample(g_SamplerState, texcoord + offset_left).rgb;
    float3 right = g_Texture2D.Sample(g_SamplerState, texcoord + offset_right).rgb;
    float3 top = g_Texture2D.Sample(g_SamplerState, texcoord + offset_top).rgb;
    float3 bottom = g_Texture2D.Sample(g_SamplerState, texcoord + offset_bottom).rgb;

    float3 blur = (center + left + right + top + bottom) / 5.0f;

    float3 sharpened = center + Amount * (center - blur);
    sharpened = saturate(sharpened);
    
    float4 color = float4(sharpened, 1.0f);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
