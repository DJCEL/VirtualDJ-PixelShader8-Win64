////////////////////////////////
// File: HighContrast.hlsl
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
}
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
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    float high = 0.6;
    float low = 0.4;

    if (color.r > high)
        color.r = 1;
    else if (color.r < low)
        color.r = 0;

    if (color.g > high)
        color.g = 1;
    else if (color.g < low)
        color.g = 0;

    if (color.b > high)
        color.b = 1;
    else if (color.b < low)
        color.b = 0;
    
    output.Color = color;
    output.Color = output.Color * input.Color;
    
    return output;
}
