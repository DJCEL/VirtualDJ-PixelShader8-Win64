////////////////////////////////
// File: Rotate.hlsl
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
    float Angle = 90.0f; // [Rotation] from 0 to 360

    if (g_FX_params_on)
    {
        Angle = ParamAdjust(g_FX_param1, 0.0f, 360.0f);
    }
    
    float2 texcoord = input.TexCoord;
    float2 texcoord2 = texcoord;
    float2 Center = float2(0.5, 0.5);
    float r = radians(Angle);
    float c = cos(r);
    float s = sin(r);
    texcoord2 -= Center; // we move to the center point before the rotation
    texcoord2 = float2(c * texcoord2.x - s * texcoord2.y, c * texcoord2.y + s * texcoord2.x);
    texcoord2 += Center; // we move to the original point after the rotation
    
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord2);

    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
