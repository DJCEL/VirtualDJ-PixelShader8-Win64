////////////////////////////////
// File: RaveTunnel.hlsl
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
    float time = g_FX_Beats_on ? g_FX_SongPosBeats : g_FX_Time;
    
    float2 texcoord = input.TexCoord;
    
    float2 center = float2(0.5f, 0.5f);
    float2 p = texcoord - center;
    float dist = length(p);
    float angle = atan2(p.y, p.x);
    float pattern = sin(dist * 20.0 - time * 6.0 + angle * 5.0);
    float v = abs(pattern);
    float4 mask = float4(v, v, v, 1.0f);
   
    float2 texcoord2 = texcoord;
    float waveOffset = pattern * 0.1;
    texcoord2 += normalize(p) * waveOffset;
    float4 texColor = g_Texture2D.Sample(g_SamplerState, texcoord2);
    
    float4 color = texColor * mask;
      
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
