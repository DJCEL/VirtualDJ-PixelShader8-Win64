////////////////////////////////
// File: Ripple.hlsl
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
float wave(float2 pos, float t, float Speed, int numWaves, float2 Center)
{
    #define PI 3.141592653589793
    float d = length(pos - Center);
    d = log(1.0f + exp(d));
    float w = 1.0f / (1.0f + 20.0f * d * d) * sin(2.0f * PI * (-numWaves * d + t * Speed));
    
    return w;
}
//--------------------------------------------------------------------------------------
float height(float2 pos, float t, float Speed, int numWaves)
{
    float2 Center = float2(0.5f, -0.5f);

    float w1 = wave(pos, t, Speed, numWaves, Center);
    float w2 = wave(pos, t, Speed, numWaves, -Center);
    
    float w = w1 + w2;
    return w;
}
//--------------------------------------------------------------------------------------
float2 normal(float2 pos, float t, float Speed, int numWaves)
{
    float2 pos_new1 = pos - float2(0.01f, 0.0f);
    float2 pos_new2 = pos - float2(0.0f, 0.01f);
    
    float val1 = height(pos_new1, t, Speed, numWaves) - height(pos, t, Speed, numWaves);
    float val2 = height(pos_new2, t, Speed, numWaves) - height(pos, t, Speed, numWaves);
    
    return float2(val1,val2);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float Speed = 2.5f;
    int numWaves = 10;
    
    if (g_FX_params_on)
    {
        Speed = ParamAdjust(g_FX_param1, 0.0f, 4.0f);
        numWaves = int(ParamAdjust(g_FX_param2, 2.0f, 20.0f));
    }
    
    float2 texcoord = input.TexCoord;
    
    float2 Center = float2(0.5, 0.5);
    float2 pos = 2.0f * (texcoord - Center);
    float2 texcoord2 = texcoord + normal(pos, g_FX_Time, Speed, numWaves);
    
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord2);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
