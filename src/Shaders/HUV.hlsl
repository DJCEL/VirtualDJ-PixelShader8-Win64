////////////////////////////////
// File: Filter.hlsl
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
float3 rgb_to_yuv(float3 RGB)
{
    float y = 0.299 * RGB.r + 0.587 * RGB.g + 0.114 * RGB.b;
    float u = 0.565 * (RGB.b - y);
    float v = 0.713 * (RGB.r - y);
    
    float3 YUV = float3(y, u, v);
    return YUV;
}
//--------------------------------------------------------------------------------------
float3 yuv_to_rgb(float3 YUV)
{
    float r = YUV.x + 1.403 * YUV.z;
    float g = YUV.x - 0.344 * YUV.y - 1.403 * YUV.z;
    float b = YUV.x + 1.770 * YUV.y;
    
    float3 RGB = float3(r, g, b);
    return RGB;
}
//--------------------------------------------------------------------------------------
float __min_channel(float3 v)
{
    float t = (v.x < v.y) ? v.x : v.y;
    t = (t < v.z) ? t : v.z;
    return t;
}
//--------------------------------------------------------------------------------------
float __max_channel(float3 v)
{
    float t = (v.x > v.y) ? v.x : v.y;
    t = (t > v.z) ? t : v.z;
    return t;
}
//--------------------------------------------------------------------------------------
float3 rgb_to_hsv(float3 RGB)
{
    float3 HSV = float3(0,0,0);
    float minVal = __min_channel(RGB);
    float maxVal = __max_channel(RGB);
    float delta = maxVal - minVal; // Delta RGB value 
    HSV.z = maxVal;
    if (delta != 0)
    { // If gray, leave H & S at zero
        HSV.y = delta / maxVal;
        float3 delRGB;
        delRGB = (((maxVal.xxx - RGB) / 6.0) + (delta / 2.0)) / delta;
        if (RGB.x == maxVal)
            HSV.x = delRGB.z - delRGB.y;
        else if (RGB.y == maxVal)
            HSV.x = (1.0 / 3.0) + delRGB.x - delRGB.z;
        else if (RGB.z == maxVal)
            HSV.x = (2.0 / 3.0) + delRGB.y - delRGB.x;
        if (HSV.x < 0.0)
        {
            HSV.x += 1.0;
        }
        if (HSV.x > 1.0)
        {
            HSV.x -= 1.0;
        }
    }
    return HSV;
}
//--------------------------------------------------------------------------------------
float3 hsv_to_rgb(float3 HSV)
{
    float3 RGB = HSV.z;
    if (HSV.y != 0)
    {
        float var_h = HSV.x * 6;
        float var_i = floor(var_h);
        float var_1 = HSV.z * (1.0 - HSV.y);
        float var_2 = HSV.z * (1.0 - HSV.y * (var_h - var_i));
        float var_3 = HSV.z * (1.0 - HSV.y * (1 - (var_h - var_i)));
        if (var_i == 0)
        {
            RGB = float3(HSV.z, var_3, var_1);
        }
        else if (var_i == 1)
        {
            RGB = float3(var_2, HSV.z, var_1);
        }
        else if (var_i == 2)
        {
            RGB = float3(var_1, HSV.z, var_3);
        }
        else if (var_i == 3)
        {
            RGB = float3(var_1, var_2, HSV.z);
        }
        else if (var_i == 4)
        {
            RGB = float3(var_3, var_1, HSV.z);
        }
        else
        {
            RGB = float3(HSV.z, var_1, var_2);
        }
    }
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
float4 sepia(float2 texcoord)
{
    float Desat = 0.5f; // [Desaturation] from 0 to 1
    float Toned = 0.5f; // [Toning] from 0 to 1
    float3 LightColor = float3(1, 0.9, 0.5); // Paper Tone
    float3 DarkColor = float3(0.2, 0.05, 0); // Stain Tone
        
    float4 texColor = g_Texture2D.Sample(g_SamplerState, texcoord);
    float3 scnColor = LightColor * texColor.xyz;
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    float gray = dot(grayXfer, scnColor);
    float3 muted = lerp(scnColor, gray.xxx, Desat);
    float3 sepia = lerp(DarkColor, LightColor, gray);
    float3 result = lerp(muted, sepia, Toned);
    return float4(result, 1);
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
    output.Color = sepia(texcoord);
    
    output.Color = output.Color * input.Color;
    
    return output;
}
