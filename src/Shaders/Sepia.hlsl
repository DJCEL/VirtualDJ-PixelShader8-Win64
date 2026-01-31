////////////////////////////////
// File: Sepia.hlsl
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
    float g_FX_param1;
    float g_FX_param2;
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
    float Desat = 0.5f; // g_FX_param1; // [Desaturation] from 0.0f to 1.0f
    float Toned = 0.6f; //g_FX_param2; // [Toning] from 0.0f to 1.0f
    float3 LightColor = float3(1, 0.9, 0.5); // Paper Tone
    float3 DarkColor = float3(0.2, 0.05, 0); // Stain Tone
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    float4 texColor = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 scnColor = LightColor * texColor.rgb;
    float gray = dot(grayXfer, scnColor);
    float3 muted = lerp(scnColor, gray.xxx, Desat);
    float3 sepia = lerp(DarkColor, LightColor, gray);
    float3 result = lerp(muted, sepia, Toned);
    output.Color = float4(result, 1.0f);
    
    output.Color = output.Color * input.Color;
    
    return output;
}
