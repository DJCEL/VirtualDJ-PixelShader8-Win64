////////////////////////////////
// File: Frozen.hlsl
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
float randf(float2 texcoord, float rnd_scale)
{
    float2 vf1 = float2(92.0, 80.0);
    float2 vf2 = float2(41.0, 62.0);
    
    float x = dot(texcoord, vf1);
    float y = dot(texcoord, vf2);
    float res = sin(x) + cos(y) * rnd_scale;
    return frac(res);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float scale = 5.1;
    float factor = 0.05;
    
    if (g_FX_params_on == 1.0f)
    {
        scale = ParamAdjust(g_FX_param1, 1.0f, 10.0f);
        factor = ParamAdjust(g_FX_param2, 0.0f, 0.10f);
    }
 
    float2 texcoord = input.TexCoord;
    float2 texcoord2 = texcoord;
    
    float2 rnd = float2(randf(texcoord.xy, scale), randf(texcoord.yx, scale));
    texcoord2 += rnd * factor;
    
    float3 col = g_Texture2D.Sample(g_SamplerState, texcoord2).rgb;
    
    float4 color = float4(col, 1.0);
      
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
