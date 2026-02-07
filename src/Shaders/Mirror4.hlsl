////////////////////////////////
// File: Mirror4.hlsl
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
float mod(float x, float y)
{
    return (x - y * floor(x / y));
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    int inverted = 0;
    
    if (g_FX_params_on)
    {
        inverted = int(round(ParamAdjust(g_FX_param1, 0.0f, 1.0f)));
    }
    
    float2 texcoord = input.TexCoord;
        
    float2 uv = texcoord;
    uv -= float2(0.5f, 0.5f);

    float2 uv2 = uv * 2.;

    float doFlip = 0.0;
    if (abs(uv2.x) > 1.0)
    {
        float mX = floor(uv2.x);
        doFlip = mod(mX, 2.0f);
    }
    else if (uv2.x < 0.0)
    {
        doFlip = 1.0;
    }

    float doFlipY = 0.0;
    if (abs(uv2.y) > 1.0)
    {
        float mY = floor(uv2.y);
        doFlipY = mod(mY, 2.0f);
    }
    else if (uv2.y < 0.0)
    {
        doFlipY = 1.0;
    }

    uv2.x = mod(uv2.x, 1.0);
    uv2.y = mod(uv2.y, 1.0);
    
    if (doFlip == 1.0)
    {
        uv2.x = 1.0 - uv2.x;
    }
    
    if (doFlipY == 1.0 && inverted == 1)
    {
        uv2.y = 1.0 - uv2.y;
    }
    
    if (doFlipY == 0.0 && inverted == 0)
    {
        uv2.y = 1.0 - uv2.y;
    }
        

    float4 colBlack = float4(0.0, 0.0, 0.0, 0.0);
    
    float4 col = g_Texture2D.Sample(g_SamplerState, uv2);
    
    float4 color = lerp(col, colBlack, 0.0f);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}