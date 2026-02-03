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
    float g_FX_Time;
    float g_FX_Width;
    float g_FX_Height;
    float g_FX_params_on;
    float g_FX_param1;
    float g_FX_param2;
    float g_FX_param3;
    float g_FX_param4;
    float g_FX_param5;
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
float ParamAdjust(float value, float ValMin, float ValMax)
{
    return ValMin + value * (ValMax - ValMin);
}
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
    float luminance = color.r * 0.299f + color.g * 0.587f + color.b * 0.114f;
    color = float4(luminance, luminance, luminance, color.a);
    return color;
}
//--------------------------------------------------------------------------------------
float4 grayscale_method2(float4 color)
{
    // average method: less accurate results
    float avg = avgRGB(color.rgb);
    color = float4(avg, avg, avg, color.a);
    return color;
}
//--------------------------------------------------------------------------------------
float4 grayscale_method3(float4 color)
{
    // neutrality method
    color.g = color.r;
    color.b = color.r;
    return color;
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    int method = 1;
    
    if (g_FX_params_on)
    {
        method = int(ParamAdjust(g_FX_param1, 1.0f, 3.0f));
    }
    
    float2 texcoord = input.TexCoord;
    float4 texcolor = g_Texture2D.Sample(g_SamplerState, texcoord);
    float4 color = 0;
    
    switch (method)
    {
        case 1:
            color = grayscale_method1(texcolor);
            break;
        case 2:
            color = grayscale_method2(texcolor);
            break;
        case 3:
            color = grayscale_method3(texcolor);
            break;
    }
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}









