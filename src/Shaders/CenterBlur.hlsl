////////////////////////////////
// File: CenterBlur.hlsl
////////////////////////////////

//--------------------------------------------------------------------------------------
// Textures and Samplers
//--------------------------------------------------------------------------------------
Texture2D g_Texture2D : register(t0);
SamplerState g_SamplerState : register(s0);

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
    float fBlurAmont = 0.25;
    float Center = 0.5;
    float4 rgbaAvgValue = 0;
    float scale = 0;
    int SAMPLECOUNT = 15;
    float DENOM = 14.0;
    float2 texcoord = 0;
    float4 textureRGBA = 0;

    input.TexCoord -= Center;

    for (int i = 0; i < SAMPLECOUNT; i++)
    {
        scale = 1.0 + fBlurAmont * (i / DENOM);
        texcoord = input.TexCoord * scale + Center;
        textureRGBA = g_Texture2D.Sample(g_SamplerState, texcoord);
        rgbaAvgValue += textureRGBA;
    }
    rgbaAvgValue /= SAMPLECOUNT;
    
    output.Color = rgbaAvgValue;
    output.Color = output.Color * input.Color;
    
    return output;
}
