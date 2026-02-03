////////////////////////////////
// File: GrayScale.hlsl
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
// Additional functions
//--------------------------------------------------------------------------------------
float avgRGB(float3 RGB)
{
    float avg = (RGB.r + RGB.g + RGB.b) / 3.0f;
    return avg;
}
//--------------------------------------------------------------------------------------
float4 grayscale_method1(float4 color)
{
    // luminance method : best method
    float luminance = dot(color.rgb, float3(0.299f, 0.587f, 0.114f));
    color = float4(luminance, luminance, luminance, color.a);
    return color;
}
//--------------------------------------------------------------------------------------
float4 grayscale_method2(float4 color)
{
    // neutrality method
    color.g = color.r;
    color.b = color.r;
    return color;
}
//--------------------------------------------------------------------------------------
float4 grayscale_method3(float4 color)
{
    // average method: less accurate results
    float avg = avgRGB(color.rgb);
    color = float4(avg, avg, avg, color.a);
    return color;
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float2 texcoord = input.TexCoord;
    float4 texcolor = g_Texture2D.Sample(g_SamplerState, texcoord);

    //float4 color = grayscale_method1(texcolor);
    float4 color = grayscale_method2(texcolor);
    //float4 color = grayscale_method3(texcolor);

    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}









