////////////////////////////////
// File: PixelsHide.hlsl
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
    int Step = 2;
    
    if (g_FX_params_on)
    {
        Step = int(ParamAdjust(g_FX_param1, 2.0f, 8.0f));
    }

    float2 texcoord = input.TexCoord;
    float2 position = input.Position.xy;
    uint2 pixelCoord = uint2(position);
    float4 color = 0;
    
	// Check if the pixel is every other pixel
    if ((pixelCoord.x % Step == 0) && (pixelCoord.y % Step == 0))
    {
        color = g_Texture2D.Sample(g_SamplerState, texcoord);
    }
    else
    {
        color = float4(0.0f, 0.0f, 0.0f, 1.0f);
    }

    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}


