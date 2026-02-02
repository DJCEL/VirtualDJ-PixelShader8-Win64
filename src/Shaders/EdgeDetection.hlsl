////////////////////////////////
// File: EdgeDetection.hlsl
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
float avgRGB(float3 RGB)
{
    return (RGB.r + RGB.g + RGB.b) / 3.;
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    
    float2 texcoord2 = texcoord - float2(0.01f, 0.01f);
    
    float4 texcolor = g_Texture2D.Sample(g_SamplerState, texcoord);
    float4 texcolor2 = g_Texture2D.Sample(g_SamplerState, texcoord2);
    
    float3 deltacolor = abs(texcolor.rgb - texcolor2.rgb);
    float3 inv_deltacolor = 1.0f - deltacolor;
    float avg = avgRGB(inv_deltacolor);
    float component = pow(avg, 5.0f);
    
    output.Color = float4(component, component, component, 1.0f);
    output.Color = output.Color * input.Color;
    
    return output;
}
