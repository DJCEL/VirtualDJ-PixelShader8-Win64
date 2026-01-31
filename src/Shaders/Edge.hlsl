////////////////////////////////
// File: Edge.hlsl
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
    bool g_FX_params_on;
    float g_FX_param1;
    float g_FX_param2;
    float g_FX_param3;
    float g_FX_param4;
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
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    
    float OffX = 0.003; //  from -0.1 to 0.1
    float OffY = 0.003; // from -0.1 to 0.1
    float Scale = 1.0; // g_FX_param1 [Scale] from 0.95 to 1.05   
    float Rot = 0.0f; // g_FX_param2 [Rot] from -2 to 2
    float Density = 1.0f; // g_FX_param3 [Density] from 0 to 1
    
    float r = radians(Rot);
    float c = cos(r);
    float s = sin(r);
    float2 nuv = Scale * (texcoord.xy - float2(0.5, 0.5));
    nuv = float2(c * nuv.x - s * nuv.y, c * nuv.y + s * nuv.x);
    nuv += float2(0.5 + OffX, 0.5 + OffY);
    float4 texCol0 = g_Texture2D.Sample(g_SamplerState, texcoord);
    float4 texCol1 = g_Texture2D.Sample(g_SamplerState, nuv);
    float3 result = saturate(texCol0.rgb - Density * (texCol1.rgb));
    
    output.Color = float4(result, texCol0.w); // protect alpha

    output.Color = output.Color * input.Color;
    
    return output;
}
