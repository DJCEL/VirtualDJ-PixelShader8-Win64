////////////////////////////////
// File: PixelsHide.hlsl
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
    float2 position = input.Position.xy;
    float2 texcoord = input.TexCoord;
    uint2 pixelCoord = uint2(position);
    float4 color = 0;

	// Check if the pixel is every other pixel
    if ((pixelCoord.x % 2 == 0)   && (pixelCoord.y % 2 == 0))
    {
        color = g_Texture2D.Sample(g_SamplerState, texcoord);
    }
    else
    {
        color = float4(0.0f, 0.0f, 0.0f, 1.0f);
    }

    output.Color = color;
    output.Color = output.Color * input.Color;
	
    return output;
}
