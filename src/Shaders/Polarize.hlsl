////////////////////////////////
// File: Polarize.hlsl
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
    float g_FX_Beats_on;
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
float min_RGB(float3 RGB)
{
    float t = (RGB.r < RGB.g) ? RGB.r : RGB.g;
    t = (t < RGB.b) ? t : RGB.b;
    return t;
}
//--------------------------------------------------------------------------------------
float max_RGB(float3 RGB)
{
    float t = (RGB.r > RGB.g) ? RGB.r : RGB.g;
    t = (t > RGB.b) ? t : RGB.b;
    return t;
}
//--------------------------------------------------------------------------------------
float3 rgb_to_hsv(float3 RGB)
{
    float r = RGB.r;
    float g = RGB.g;
    float b = RGB.b;
    float h = 0.0f;
    float s = 0.0f;
    float v = 0.0f;
    
    float minValRGB = min_RGB(RGB);
    float maxValRGB = max_RGB(RGB);
    float delta = maxValRGB - minValRGB;
    if (delta != 0)
    {
        v = maxValRGB;
        s = delta / maxValRGB;
        float3 maxRGB = float3(maxValRGB,maxValRGB,maxValRGB);
        float3 deltaRGB = (((maxRGB - RGB) / 6.0) + (delta / 2.0)) / delta;
        float dr = deltaRGB.x;
        float dg = deltaRGB.y;
        float db = deltaRGB.z;
        if (r == maxValRGB)
            h = db - dg;
        else if (g == maxValRGB)
            h = (1.0 / 3.0) + dr - db;
        else if (b == maxValRGB)
            h = (2.0 / 3.0) + dg - dr;
        if (h < 0.0)
        {
            h += 1.0;
        }
        if (h > 1.0)
        {
            h -= 1.0;
        }
    }
    
    float3 HSV = float3(h, s, v);
    return HSV;
}
//--------------------------------------------------------------------------------------
float3 hsv_to_rgb(float3 HSV)
{
    float h = HSV.x;
    float s = HSV.y;
    float v = HSV.z;
    float r = 0.0f;
    float g = 0.0f;
    float b = 0.0f;
    
    if (s != 0)
    {
        float var_j = h * 6;
        float var_i = floor(var_j);
        float var_1 = v * (1.0 - s);
        float var_2 = v * (1.0 - s * (var_j - var_i));
        float var_3 = v * (1.0 - s * (1 - (var_j - var_i)));
        if (var_i == 0)
        {
            r = v;
            g = var_3;
            b = var_1;
        }
        else if (var_i == 1)
        {
            r = var_2;
            g = v;
            b = var_1;;
        }
        else if (var_i == 2)
        {
            r = var_1;
            g = v;
            b = var_3;
        }
        else if (var_i == 3)
        {
            r = var_1;
            g = var_2;
            b = v;
        }
        else if (var_i == 4)
        {
            r = var_3;
            g = var_1;
            b = v;
        }
        else
        {
            r = v;
            g = var_1;
            b = var_2;
        }
    }
    
    float3 RGB = float3(r, g, b);
    return RGB;
}
//--------------------------------------------------------------------------------------
float3 hsv_complement(float3 InColor)
{
    float3 complement = InColor;
    complement.x -= 0.5;
    if (complement.x < 0.0)
    {
        complement.x += 1.0;
    }
    return complement;
}
//--------------------------------------------------------------------------------------
float hue_lerp(float h1, float h2, float v)
{
    float d = abs(h1 - h2);
    if (d <= 0.5)
    {
        return (float) lerp(h1, h2, v);
    }
    else if (h1 < h2)
    {
        return (float) frac(lerp((h1 + 1.0), h2, v));
    }
    else
        return (float) frac(lerp(h1, (h2 + 1.0), v));
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float2 texcoord = input.TexCoord;
    
    float Amount = 0.6f; // [Strength of Effect] from to 0 to 1
    float Concentrate = 1.44f; // [Color Concentration] from 0.1 to 4 
    float DesatCorr = 0.12f; //  [Desaturate Correction] from to 0 to 1
    float3 GuideHueRGB = float3(0.0, 0.0, 1.0);
        
    if (g_FX_params_on)
    {
        Amount = ParamAdjust(g_FX_param1, 0.0f, 1.0f);
        Concentrate = ParamAdjust(g_FX_param2, 0.1f, 4.0f);
        DesatCorr = ParamAdjust(g_FX_param3, 0.0f, 1.0f);
        int GuideHueRGB_select = int(round(ParamAdjust(g_FX_param4, 1.0f, 3.0f)));
        switch (GuideHueRGB_select)
        {
            case 1:
                GuideHueRGB = float3(1.0, 0.0, 0.0); // red
                break;
            case 2:
                GuideHueRGB = float3(0.0, 1.0, 0.0); // green
                break;
            case 3:
                GuideHueRGB = float3(0.0, 0.0, 1.0); // blue
                break;
        }
    }
    
    float4 rgbaTex = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 hsvTex = rgb_to_hsv(rgbaTex.rgb);
    float3 huePole1 = rgb_to_hsv(GuideHueRGB);
    float3 huePole2 = hsv_complement(huePole1);
    float dist1 = abs(hsvTex.x - huePole1.x);
    if (dist1 > 0.5)
        dist1 = 1.0 - dist1;
    float dist2 = abs(hsvTex.x - huePole2.x);
    if (dist2 > 0.5)
        dist2 = 1.0 - dist2;
    float dsc = smoothstep(0, DesatCorr, hsvTex.y);
    float3 newHsv = hsvTex;

    if (Concentrate < 0.1f)
    {
        Concentrate = 0.1f;
    }
    float e = 1.0 / Concentrate;
    if (dist1 < dist2)
    {
        float f = dist1 * 2.0;
        float c = dsc * Amount * (1.0 - pow(abs(f), e));
        newHsv.x = hue_lerp(hsvTex.x, huePole1.x, c);
        newHsv.y = lerp(hsvTex.y, huePole1.y, c);
    }
    else
    {
        float f = dist2 * 2.0;
        float c = dsc * Amount * (1.0 - pow(abs(f), e));
        newHsv.x = hue_lerp(hsvTex.x, huePole2.x, c);
        newHsv.y = lerp(hsvTex.y, huePole1.y, c);
    }
    
    float3 newRGB = hsv_to_rgb(newHsv);
        
    float4 color = float4(newRGB.rgb, rgbaTex.a);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
