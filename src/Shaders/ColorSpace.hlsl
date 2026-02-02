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
float ParamAdjust(float value, float ValMin, float ValMax)
{
    return ValMin + value * (ValMax - ValMin);
}
//--------------------------------------------------------------------------------------
float sRGBtoLin(float colorRGB)
{
    // colorRGB : gamma-encoded R,G,B channel of RGB
    float lin = 0.0f;
    
    if (colorRGB <= 0.04045f)
    {
        lin = colorRGB / 12.92f;
    }
    else
    {
        lin = (colorRGB + 0.055f) / 1.055f;
        lin = pow(lin, 2.4f);
    }
       
    return lin;
}
//--------------------------------------------------------------------------------------
float get_luminance(float3 RGB)
{
    float R = RGB.r;
    float G = RGB.g;
    float B = RGB.b;
    
    // In 8-bit RGB (255) : red=90 / green=115 / blue=51
    float luminance_1 = 0.353f * R + 0.451f * G + 0.196f * B;
 
    // Perceived
    float luminance_2 = 0.299f * R + 0.587f * G + 0.114f * B;
    
    // Standard
    float luminance_3 = 0.2126f * sRGBtoLin(R) + 0.7152f * sRGBtoLin(G) + 0.0722f * sRGBtoLin(B);
    
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
        lightness = pow(luminance, (1 / 3)) * 116 - 16;
    }
    
    return lightness;
}
//--------------------------------------------------------------------------------------
float3 rgb_to_yuv(float3 RGB)
{
    // y : luminance (linear) => brightness (greyscale) or luma (gamma-corrected) => intensity
    // u (Cb) and v (Cr) : chrominance components => color information
    float R = RGB.r;
    float G = RGB.g;
    float B = RGB.b;
    
    float Y = 0.299 * R + 0.587 * G + 0.114 * B;
    float U = -0.14714119 * R - 0.28886916 * G + 0.43601035 * B; // = (B - Y) * 0.565;
    float V = 0.61497538 * R - 0.51496512 * G - 0.10001026 * B; //  = (R - Y) * 0.713;
    
    float3 YUV = float3(Y, U, V);
    return YUV;
}
//--------------------------------------------------------------------------------------
float3 yuv_to_rgb(float3 YUV)
{
    float Y = YUV.x;
    float U = YUV.y;
    float V = YUV.z;
    
    float R = Y + 1.403f * V;
    float G = Y - 0.344f * U - 0.714f * V;
    float B = Y + 1.770f * U;
    
    if (R > 1.0f)
        R = 1.0f;
    if (G > 1.0f)
        G = 1.0f;
    if (B > 1.0f)
        B = 1.0f;
    
    float3 RGB = float3(R, G, B);
    return RGB;
}
//--------------------------------------------------------------------------------------
float3 rgb_to_YCbCr(float3 RGB)
{
    // y : luminance (linear) => brightness (greyscale) or luma (gamma-corrected) => intensity
    // u (Cb) and v (Cr) : chrominance components => color information
    float R = RGB.r;
    float G = RGB.g;
    float B = RGB.b;
    
    float Y = 0.257f * R + 0.504f * G + 0.098f * B;
    float Cb = -0.148f * R - 0.291f * G + 0.439f * B;
    float Cr = 0.439f * R - 0.368f * G - 0.071f * B;
   
    float3 YCbCr = float3(Y, Cb, Cr);
    return YCbCr;
}
//--------------------------------------------------------------------------------------
float3 YCbCr_to_rgb(float3 YCbCr)
{
    float Y = YCbCr.x;
    float Cb = YCbCr.y;
    float Cr = YCbCr.z;
    
    float R = 1.164f * Y + 1.596f * Cr;
    float G = 1.164f * Y - 0.813f * Cr - 0.392f * Cb;
    float B = 1.164f * Y + 2.017f * Cb;
    
    if (R > 1.0f)
        R = 1.0f;
    if (G > 1.0f)
        G = 1.0f;
    if (B > 1.0f)
        B = 1.0f;
    
    float3 RGB = float3(R, G, B);
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
    // HSV: hue, saturation, and value
    
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
        float3 maxRGB = float3(maxValRGB, maxValRGB, maxValRGB);
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
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float adjust_C1 = 0.0f;
    float adjust_C2 = 1.0f;
    float adjust_C3 = 1.0f;
    float adjust_C4 = 0.0f;
    int ColorSpace_select = 1;
    
    if (g_FX_params_on)
    {
        ColorSpace_select = int(ParamAdjust(g_FX_param1, 1.0f, 5.0f));
        adjust_C1 = ParamAdjust(g_FX_param2, 0.0f, 1.0f);
        adjust_C2 = ParamAdjust(g_FX_param3, 0.0f, 1.0f);
        adjust_C3 = ParamAdjust(g_FX_param4, 0.0f, 1.0f);
        adjust_C4 = ParamAdjust(g_FX_param5, 0.0f, 1.0f);
    }
    
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    
    float4 TexColor = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 RGB = TexColor.rgb;
    float3 outRGB = float3(1.0f, 1.0f, 1.0f);
    
    if (ColorSpace_select == 1)
    {
        outRGB = RGB;
        
        if (g_FX_params_on)
        {
            outRGB.r *= adjust_C1;
            outRGB.g *= adjust_C2;
            outRGB.b *= adjust_C3;
        }
        else
        {
            float3 vDelta = float3(0.0f, 2.0f, 4.0f);
            float3 adjust = 0.5f + 0.5f * cos(iTime + texcoord.xyx + vDelta);
            outRGB *= adjust;
        }
    }
    else if (ColorSpace_select == 2)
    {
        float3 YCbCr = rgb_to_YCbCr(RGB);
        YCbCr.x *= adjust_C1;
        YCbCr.y *= adjust_C2;
        YCbCr.z *= adjust_C3;
        outRGB = YCbCr_to_rgb(YCbCr);
    }
    else if (ColorSpace_select == 3)
    {
        float3 YUV = rgb_to_yuv(RGB);
        YUV.x *= adjust_C1;
        YUV.y *= adjust_C2;
        YUV.z *= adjust_C3;
        outRGB = yuv_to_rgb(YUV);
    }
    else if (ColorSpace_select == 4)
    {
        float3 HSV = rgb_to_hsv(RGB);
        HSV.x *= adjust_C1;
        HSV.y *= adjust_C2;
        HSV.z *= adjust_C3;
        outRGB = hsv_to_rgb(HSV);
    }
    else if (ColorSpace_select == 5)
    {
        float4 CMYK = rgb_to_cmyk(RGB);
        CMYK.x *= adjust_C1;
        CMYK.y *= adjust_C2;
        CMYK.z *= adjust_C3;
        CMYK.w *= adjust_C4;
        outRGB = cmyk_to_rgb(CMYK);
    }
   
    output.Color = float4(outRGB.r, outRGB.g, outRGB.b, TexColor.a);

    output.Color = output.Color * input.Color;
    
    return output;
}
