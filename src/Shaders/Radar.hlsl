////////////////////////////////
// File: Radar.hlsl
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
float mod(float x, float y)
{
    float m = x - y * floor(x / y);
    
    return m;
}
//--------------------------------------------------------------------------------------
float d2y(float d)
{
    return 1. / (0.2f + d);
}
//--------------------------------------------------------------------------------------
float radar(float2 p, float r, float radius, float time, bool inverted)
{
    float angle = atan2(p.y, p.x);
    const float cste = 3.0f;
    const float TWO_PI = 2.0f * 3.14159265359;
    float x = -angle;
    if (inverted)
        x -= time;
    else
        x += time;
 
    float a = cste * mod(x, TWO_PI);
	
    return d2y(a) * (1.0f - step(radius, r));
}
//--------------------------------------------------------------------------------------
float circle(float2 p, float r, float radius)
{
    float d = distance(r, radius);
    return d2y(100.f * d);
}
//--------------------------------------------------------------------------------------
float grid_background(float2 p, float y)
{
    float alpha = 0.2f;
    float res = 30.0f;
    float e = 0.1f;
    float2 pi = frac(p * res);
    pi = step(e, pi);
    return alpha * y * pi.x * pi.y;
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float time = g_FX_Beats_on ? g_FX_SongPosBeats : g_FX_Time;
    
    float colorRadarId = 1;
    float speed = 1.0f;
    float radius = 0.45f;
    bool grid_on = false;
    bool inverted = false;
    
    if (g_FX_params_on == 1.0f)
    {
        speed = ParamAdjust(g_FX_param1, 0.0f, 10.0f);
        radius = ParamAdjust(g_FX_param2, 0.0f, 1.0f);
        grid_on = (int(round(ParamAdjust(g_FX_param3, 0.0f, 1.0f))) == 1) ? true : false;
        inverted = (int(round(ParamAdjust(g_FX_param4, 0.0f, 1.0f))) == 1) ? true : false;
        colorRadarId = int(round(ParamAdjust(g_FX_param5, 1.0f, 2.0f)));

    }
    
    float3 colorRadar = float3(0.0f, 0.0f, 0.0f);
    switch(colorRadarId)
    {
        case 1:
            colorRadar = float3(1.0f, 1.0f, 1.0f); // white
            break;
        case 2:
            colorRadar = float3(0.15f, 0.3f, 0.15f); // light green
            break;
    }
        
    float2 texcoord = input.TexCoord;
    float4 texColor = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    float2 center = float2(0.5f, 0.5f);
    float2 position = texcoord - center;
    
    float video_ratio = g_FX_Width / g_FX_Height;
    position.x *= video_ratio; // to keep a true circle
    
    float len = length(position);
    
    position /= cos(0.125f * len);
    float y = 0.0f;
	
    float dc = length(position);
    float time_fixed = time * speed;
	
    y += radar(position, dc, radius, time_fixed, inverted);
    y += circle(position, dc, radius);
    if (grid_on)
    {
        y += grid_background(position, y);
    }
    y = pow(abs(y), 1.75f);
    
    float3 col = sqrt(y) * colorRadar;
    
    float4 mask = float4(col, 1.0f);
    
    float4 color = mask * texColor;
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
