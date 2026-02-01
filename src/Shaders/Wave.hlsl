////////////////////////////////
// File: Wave.hlsl
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
    int iResolutionWidth;
    int iResolutionHeight;
    float iTime;
    bool g_FX_params_on;
    float g_FX_param1;
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
    float fAdjust = 1.0f;
    
    if (g_FX_params_on)
    {
        fAdjust = ParamAdjust(g_FX_param1, 0.0f, 2.0f);
    }
    
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
        
    float2 texcoord2 = texcoord;
    texcoord2.x += sin(iTime * fAdjust + texcoord2.x * 10) * 0.01f;
    texcoord2.y += cos(iTime * fAdjust + texcoord2.y * 10) * 0.01f;

    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord2);
    
    output.Color = color;
    output.Color = output.Color * input.Color;
    
    return output;
}
