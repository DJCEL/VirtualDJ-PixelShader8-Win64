////////////////////////////////
// File: FishEye.hlsl
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
    float Distortion = 1.0f;
    float MaxRadius = 0.50f;
    

    if (g_FX_params_on == 1.0f)
    {
        Distortion = ParamAdjust(g_FX_param1, 0.0f, 5.0f);
        MaxRadius = ParamAdjust(g_FX_param2, 0.0f, 1.0f);
    }

    float2 texcoord = input.TexCoord;
    float2 Centre = float2(0.5f, 0.5f);
    float2 size = float2(g_FX_Width, g_FX_Height);
    float2 centrePx = Centre * size;
    float2 delta = texcoord * size - centrePx;

    float currentRadius = max(length(delta), 0.0001f);
    float maxRadiusPx = MaxRadius * length(size * 0.5f);


    float inside = (currentRadius < maxRadiusPx) ? 1.0f : 0.0f;
    float acosResult = acos(saturate(currentRadius / maxRadiusPx));
    float scale = 1.0f / (1.0f + acosResult * Distortion);

    float2 srcUV = (centrePx + delta * scale) / size;

    float4 color_tmp = g_Texture2D.Sample(g_SamplerState, srcUV);
    float4 color = color_tmp * inside;
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
