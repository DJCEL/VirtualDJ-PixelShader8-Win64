////////////////////////////////
// File: ColorDistorsion.hlsl
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
// Additional Functions
//--------------------------------------------------------------------------------------
float wave(float x, float amount)
{
    return (sin(x * amount) + 1.) * .5;
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    PS_OUTPUT output;
    float amount_red = 10.0;
    float amount_green = 20.0;
    float amount_blue = 40.0;
    
    float2 texcoord = input.TexCoord;
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    color.r = wave(color.r, amount_red);
    color.g = wave(color.g, amount_green);
    color.b = wave(color.b, amount_blue);
    
    output.Color = color;
    output.Color = output.Color * input.Color;
    
    return output;
}
