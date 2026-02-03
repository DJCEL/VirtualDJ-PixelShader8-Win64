////////////////////////////////
// File: Mask.hlsl
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
    bool  g_FX_params_on;
    float g_FX_param1;
    float g_FX_param2;
    float g_FX_param3;
    float g_FX_param4;
    float g_FX_param5;
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
float ParamAdjust(float value,float ValMin,float ValMax)
{
    return ValMin + value * (ValMax - ValMin);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float2 texcoord = input.TexCoord;
    
    float OffX = 0.003; // [OffsetX] from -0.1 to 0.1
    float OffY = 0.003; // [OffsetY] from -0.1 to 0.1
    float Scale = 1.0; // [Scale] from 0.95 to 1.05   
    float Rot = 0.0f; // [Rotation] from -2 to 2
    float Density = 1.0f; // [Density] from 0 to 1
    
    if (g_FX_params_on)
    {
        OffX = ParamAdjust(g_FX_param1, -0.1f, 0.1f);
        OffY = ParamAdjust(g_FX_param2, -0.1f, 0.1f);
        Scale = ParamAdjust(g_FX_param3, 0.95f, 1.0f);
        Rot = ParamAdjust(g_FX_param4, -2.0f, 2.0f);
        Density = ParamAdjust(g_FX_param5, 0.0f, 1.0f);
    }
    
    float2 Center = float2(0.5, 0.5);
    float r = radians(Rot);
    float c = cos(r);
    float s = sin(r);
    float2 nuv = Scale * (texcoord.xy - Center);
    nuv = float2(c * nuv.x - s * nuv.y, c * nuv.y + s * nuv.x);
    nuv += float2(0.5 + OffX, 0.5 + OffY);
    float4 texCol0 = g_Texture2D.Sample(g_SamplerState, texcoord);
    float4 texCol1 = g_Texture2D.Sample(g_SamplerState, nuv);
    float3 mix_texCol = texCol0.rgb - Density * (texCol1.rgb);
    float3 result = saturate(mix_texCol);
    
    float4 color = float4(result, texCol0.a); // protect alpha
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
