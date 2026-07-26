////////////////////////////////
// File: Sharpen.hlsl
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
    float sharpness = 1.0f;
    if (g_FX_params_on == 1.0f)
    {
        sharpness = ParamAdjust(g_FX_param1, 0.0f, 3.0f);
    }
    
    float2 texcoord = input.TexCoord;
    float2 u_textureSize = float2(g_FX_Width, g_FX_Height);
    float2 texel = 1.0f / u_textureSize;
    
    const int KERNEL_SIZE = 9;
    
    // 3x3 kernel offsets for neighboring pixels
    float2 offsets[KERNEL_SIZE] =
    {
        float2(-texel.x, texel.y), // top-left
        float2(0.0f, texel.y), // top-center
        float2(texel.x, texel.y), // top-right
        float2(-texel.x, 0.0f), // center-left
        float2(0.0f, 0.0f), // center
        float2(texel.x, 0.0f), // center-right
        float2(-texel.x, -texel.y), // bottom-left
        float2(0.0f, -texel.y), // bottom-center
        float2(texel.x, -texel.y) // bottom-right
    };

    // Sharpen kernel weights
    float kernel[KERNEL_SIZE] =
    {
        -1.0, -1.0, -1.0,
        -1.0, 8.0 + sharpness, -1.0,
        -1.0, -1.0, -1.0
    };

    float4 sampleSum = float4(0.0f, 0.0f, 0.0f, 0.0f);
    for (int i = 0; i < KERNEL_SIZE; i++)
    {
        float4 color = g_Texture2D.Sample(g_SamplerState, texcoord + offsets[i]);
        sampleSum += color * kernel[i];
    }

    float4 color = float4(sampleSum.rgb, 1.0f);
    
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
