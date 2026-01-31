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
    float g_FX_param2;
    float g_FX_param3;
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
        lightness = pow(luminance, (1 / 3)) * 116 - 16;
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
    
    float y = 0.299f * r + 0.587f * g + 0.114f * b;
    float u = (0.492f * (b - y)) + 0.5f;
    float v = (0.877f * (r - y)) + 0.5f;

    float3 YUV = float3(y, u, v);
    return YUV;
}
//--------------------------------------------------------------------------------------
float3 yuv_to_rgb(float3 YUV)
{
    float y = YUV.x;
    float u = YUV.y;
    float v = YUV.z;
    
    float nU = u - 0.5f;
    float nV = v - 0.5f;
    float r = y + 1.140f * nV;
    float g = y - 0.394f * nU - 0.581f * nV;
    float b = y + 2.032f * nU;
   
    float3 RGB = float3(r, g, b);
    return RGB;
}
//--------------------------------------------------------------------------------------
float3 rgb_to_YCbCr(float3 RGB)
{
    // y : luminance (linear) => brightness (greyscale) or luma (gamma-corrected) => intensity
    // u (Cb) and v (Cr) : chrominance components => color information
    float r = RGB.r;
    float g = RGB.g;
    float b = RGB.b;
    
    // CUDA - NPP:
    float Y = 0.257f * r + 0.504f * g + 0.098f * b + 0.0625f;
    float Cb = -0.148f * r - 0.291f * g + 0.439f * b + 0.5f;
    float Cr = 0.439f * r - 0.368f * g - 0.071f * b + 0.5f;
   
    float3 YCbCr = float3(Y, Cb, Cr);
    return YCbCr;
}
//--------------------------------------------------------------------------------------
float3 YCbCr_to_rgb(float3 YCbCr)
{
    float Y = YCbCr.x;
    float Cb = YCbCr.y;
    float Cr = YCbCr.z;
    
    // CUDA - NPP:
    float nY = 1.164f * (Y - 0.0625f);
    float nR = Cr - 0.5f;
    float nB = Cb - 0.5f;
    float r = nY + 1.596f * nR;
    float g = nY - 0.813f * nR - 0.392f * nB;
    float b = nY + 2.017f * nB;
    
    if (r > 1.0f)
        r = 1.0f;
    if (g > 1.0f)
        g = 1.0f;
    if (b > 1.0f)
        b = 1.0f;
    
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
    PS_OUTPUT output;
    float2 texcoord = input.TexCoord;
    
    float4 TexColor = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 RGB = TexColor.rgb;
    
    float3 YUV = rgb_to_yuv(RGB);
    float3 YCbCr = rgb_to_YCbCr(RGB);
    float3 HSV = rgb_to_hsv(RGB);
    float4 CMYK = rgb_to_cmyk(RGB);
    
    //YUV.y = 0;
    //YUV.z = 0;
    YCbCr.x = g_FX_param1;
    YCbCr.y = g_FX_param2;
    YCbCr.z = g_FX_param3;
    
    float3 outRGB = YCbCr_to_rgb(YCbCr);
    //float3 outRGB = yuv_to_rgb(YUV);
    //float3 outRGB = hsv_to_rgb(HSV);
    //float3 outRGB = cmyk_to_rgb(CMYK);
    
    output.Color = float4(outRGB.r, outRGB.g, outRGB.b, 1.0f);

    output.Color = output.Color * input.Color;
    
    return output;
}
