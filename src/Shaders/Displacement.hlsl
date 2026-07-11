////////////////////////////////
// File: Displacement.hlsl
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
    float g_FX_SongPosBeats;
    float g_FX_Width;
    float g_FX_Height;
    float g_FX_Beats_on;
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
float stripes(float x, int steps)
{
    return frac(x * float(steps));
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float time = (g_FX_Beats_on == 1.0f) ? g_FX_SongPosBeats : g_FX_Time;
    
    float Speed = 1.0f;
    int Steps = 10;
    int Direction = 1;
    
    if (g_FX_params_on == 1.0f)
    {
        Speed = ParamAdjust(g_FX_param1, 0.0f, 30.0f);
        Steps = int(round(ParamAdjust(g_FX_param2, 2.0f, 40.0f)));
        Direction = int(round(ParamAdjust(g_FX_param3, 1.0f, 3.0f)));
    }
    
    float2 texcoord = input.TexCoord;
    float4 texcolor = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    float2 texcoord2 = texcoord;
    float value = texcolor.r * 0.1f * sin(time * Speed);
    float brightness = 0.0f;
    float brightness1 = 0.0f;
    float brightness2 = 0.0f;
    
    switch (Direction)
    {
        case 1:
            texcoord2.x += value;
            brightness = stripes(texcoord2.x, Steps);
            break;
        case 2:
            texcoord2.y += value;
            brightness = stripes(texcoord2.y, Steps);
            break;
        case 3:
            texcoord2.x += value;
            brightness1 = stripes(texcoord2.x, Steps);
            texcoord2.y += value;
            brightness2 = stripes(texcoord2.y, Steps);
            brightness = brightness1 * brightness2;
            break;
    }
    
    float4 mask = float4(brightness, brightness, brightness, 1.0f);
    
    float4 color = texcolor * mask;
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}