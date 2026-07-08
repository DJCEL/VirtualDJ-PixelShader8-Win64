////////////////////////////////
// File: SpatialDistorsion.hlsl
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
    float time = (g_FX_Beats_on == 1.0f) ? g_FX_SongPosBeats : g_FX_Time;
    
    float Speed = 3.0f;
    float Distorsion = 10.0f;
    float Depth = 0.03f;
    
    if (g_FX_params_on == 1.0f)
    {
        Speed = ParamAdjust(g_FX_param1, 0.0f, 10.0f);
        Distorsion = ParamAdjust(g_FX_param2, 0.0f, 100.0f);
        Depth = ParamAdjust(g_FX_param3, 0.01f, 0.5f);
    }
    
    
    float2 texcoord = input.TexCoord;
    float2 texcoord2 = texcoord;
    texcoord2.x = texcoord2.x + sin(texcoord2.y * Distorsion + time * Speed) * Depth;
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord2);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
