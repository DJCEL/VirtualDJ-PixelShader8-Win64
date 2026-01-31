////////////////////////////////
// File: ColorSpace.hlsl
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
float sRGBtoLin(float colorRGB)
{
    // colorRGB : gamma-encoded R,G,B channel of RGB
    float lin = 0.0f;
    
    if (colorRGB <= 0.04045)
    {
        lin = colorRGB / 12.92f;
    }
    else
    {
        lin = (colorRGB + 0.055) / 1.055;
        lin = pow(lin, 2.4);
    }
       
    return lin;
}
//--------------------------------------------------------------------------------------
float get_luminance(float3 RGB)
{
    float r = RGB.r;
    float g = RGB.g;
    float b = RGB.b;
    
    // In 8-bit RGB (255) : red=90 / green=115 / blue=51
    float luminance_1 = 0.353 * r + 0.451 * g + 0.196 * b;
 
    // Perceived
    float luminance_2 = 0.299 * r + 0.587 * g + 0.114 * b;
    
    // Standard
    float luminance_3 = 0.2126 * sRGBtoLin(r) + 0.7152 * sRGBtoLin(g) + 0.0722 * sRGBtoLin(b);
    
    return luminance_1;
}
//--------------------------------------------------------------------------------------
float get_brightness(float3 RGB)
{
    return get_luminance(RGB);
}
//--------------------------------------------------------------------------------------
float get_perceptual_lightness(float luminance)
{
    // CIE standard : 0.008856 = 216 / 24389
    // CIE standard : 903.3 = 24389 / 27
        
    float lightness = 0.0f;
    
    if (luminance <= 0.008856)
    {
        lightness = luminance * 903.3;
    }
    else
    {
        lightness = pow(luminance, (1 / 3)) * 116  - 16;
    }
    
    return lightness;
}
//--------------------------------------------------------------------------------------
float3 rgb_to_yuv(float3 RGB)
{
    // y : luminance (linear) => brightness (greyscale) or luma (gamma-corrected) => intensity
    // u (Cb) and v (Cr) : chrominance components => color information
    float r = RGB.r;
    float g = RGB.g;
    float b = RGB.b;
    float y = 0.299 * r + 0.587 * g + 0.114 * b;
    float u = 0.565 * (b - y);
    float v = 0.713 * (r - y);
    float3 YUV = float3(y, u, v);
    return YUV;
}
//--------------------------------------------------------------------------------------
float3 yuv_to_rgb(float3 YUV)
{
    float y = YUV.x;
    float u = YUV.y;
    float v = YUV.z;
    float r = y + 1.403 * v;
    float g = y - 0.344 * u - 1.403 * v;
    float b = y + 1.770 * u;
    float3 RGB = float3(r, g, b);
    return RGB;
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
float3 rgb_to_cmy(float3 RGB)
{
    float3 CMY = float3(1, 1, 1) - RGB;
    return CMY;
}
//--------------------------------------------------------------------------------------
float3 cmy_to_rgb(float3 CMY)
{
    float3 RGB = float3(1, 1, 1) - CMY;
    return RGB;
}
//--------------------------------------------------------------------------------------
float4 cmy_to_cmyk(float3 CMY)
{
    float k = ((float) 1.0);
    k = min(k, CMY.x);
    k = min(k, CMY.y);
    k = min(k, CMY.z);
    float4 CMYK;
    CMYK.xyz = (CMY - (float3) k) / ((float3) (((float) 1.0) - k).xxx);
    CMYK.w = k;
    return CMYK;
}
//--------------------------------------------------------------------------------------
float3 cmyk_to_cmy(float4 CMYK)
{
    float3 k = CMYK.www;
    float3 CMY = ((CMYK.xyz * (float3(1, 1, 1) - k)) + k);
    return CMY;
}
//--------------------------------------------------------------------------------------
float4 rgb_to_cmyk(float3 RGB)
{
    float3 CMY = rgb_to_cmy(RGB);
    float4 CMYK = cmy_to_cmyk(CMY);
    return CMYK;
}
//--------------------------------------------------------------------------------------
float3 cmyk_to_rgb(float4 CMYK)
{
    float3 CMY = cmyk_to_cmy(CMYK);
    float3 RGB = cmy_to_rgb(CMY);
    return RGB;
}
//--------------------------------------------------------------------------------------
float4 ColorSpace(float2 texcoord)
{
    float4 color = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 RGB = color.rgb;
    
    float3 HSV = rgb_to_hsv(RGB);
    //float3 YUV = rgb_to_yuv(RGB);
    //float4 CMYK = rgb_to_cmyk(RGB);
    
    float4 outcolor = float4(HSV.x, HSV.y, HSV.z, color.a);
    //outcolor = float4(YUV.x, YUV.y, YUV.z, color.a);
    //outcolor = float4(CMYK.x, CMYK.y, CMYK.z, CMYK.w);
    
    return outcolor;
}
//--------------------------------------------------------------------------------------
float4 negative2(float2 texcoord)
{
    float OffX = 0.003; // from -0.1 to 0.1
    float OffY = 0.003; // from -0.1 to 0.1
    float Scale = 1.0; // from 0.95 to 1.05   
    float Rot = 0.0f; // from -2 to 2
    float Density = 1.0f; // from 0 to 1
    
    float r = radians(Rot);
    float c = cos(r);
    float s = sin(r);
    float2 nuv = Scale * (texcoord.xy - float2(0.5, 0.5));
    nuv = float2(c * nuv.x - s * nuv.y, c * nuv.y + s * nuv.x);
    nuv += float2(0.5 + OffX, 0.5 + OffY);
    float4 texCol0 = g_Texture2D.Sample(g_SamplerState, texcoord);
    float4 texCol1 = g_Texture2D.Sample(g_SamplerState, nuv);
    float3 result = saturate(texCol0.rgb - Density * (texCol1.rgb));
    return float4(result, texCol0.w); // protect alpha
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
float4 polarize(float2 texcoord)
{
    float Amount = 0.2f; // [Strength of Effect] from to 0 to 1
    float Concentrate = 0.0f; // [Color Concentration] from 0.1 to 4 
    float DesatCorr = 0.0f; // [Desaturate Correction] from to 0 to 1
    float3 GuideHue = float3(0.0, 0.0, 1.0);
    #define FORCEHUE
    
    
    float4 rgbaTex = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 hsvTex = rgb_to_hsv(rgbaTex.rgb);
    float3 huePole1 = rgb_to_hsv(GuideHue);
    float3 huePole2 = hsv_complement(huePole1);
    float dist1 = abs(hsvTex.x - huePole1.x);
    if (dist1 > 0.5)
        dist1 = 1.0 - dist1;
    float dist2 = abs(hsvTex.x - huePole2.x);
    if (dist2 > 0.5)
        dist2 = 1.0 - dist2;
    float dsc = smoothstep(0, DesatCorr, hsvTex.y);
    float3 newHsv = hsvTex;
#ifdef FORCEHUE
    if (dist1 < dist2) {
	newHsv = huePole1;
    } else {
	newHsv = huePole2;
    }
#else /* ! FORCEHUE */
    if (dist1 < dist2)
    {
        float c = dsc * Amount * (1.0 - pow((dist1 * 2.0), 1.0 / Concentrate));
        newHsv.x = hue_lerp(hsvTex.x, huePole1.x, c);
        newHsv.y = lerp(hsvTex.y, huePole1.y, c);
    }
    else
    {
        float c = dsc * Amount * (1.0 - pow((dist2 * 2.0), 1.0 / Concentrate));
        newHsv.x = hue_lerp(hsvTex.x, huePole2.x, c);
        newHsv.y = lerp(hsvTex.y, huePole1.y, c);
    }
#endif /* ! FORCEHUE */
    float3 newRGB = hsv_to_rgb(newHsv);
#ifdef FORCEHUE
    newRGB = lerp(rgbaTex.rgb,newRGB,Amount);
#endif /* FORCEHUE */
    return float4(newRGB.rgb, rgbaTex.a);
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    
    //output.Color = ColorSpace(texcoord);
    //output.Color = negative2(texcoord);
    output.Color = polarize(texcoord);
    
    output.Color = output.Color * input.Color;
    
    return output;
}
