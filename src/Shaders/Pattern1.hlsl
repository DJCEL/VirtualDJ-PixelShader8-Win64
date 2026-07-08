////////////////////////////////
// File: Pattern1.hlsl
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
float wrap(float x)
{
    return abs(fmod(x, 2.0f) - 1.0f);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float time = (g_FX_Beats_on == 1.0f) ? g_FX_SongPosBeats : g_FX_Time;
    
    float size = 0.1f;
    
    if (g_FX_params_on)
    {
        size = ParamAdjust(g_FX_param1, 0.0f, 1.0f);
    }
    
    float2 texcoord = input.TexCoord;
    texcoord.x = fmod(texcoord.x, size);
    texcoord.x = abs(texcoord.x - size / 2.0f);
    texcoord.x = wrap(texcoord.x + time / 6.0f);
    
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
