////////////////////////////////
// File: Negative.hlsl
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
    float2 texcoord = input.TexCoord;
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    color.rgb = 1 - color.rgb;
    
    output.Color = color;
    output.Color = output.Color * input.Color;
    
    return output;
}
