////////////////////////////////
// File: Flash.hlsl
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
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float time = (g_FX_Beats_on == 1.0f) ? g_FX_SongPosBeats : g_FX_Time;
    
    float Speed = 2.0f;
    
    if (g_FX_params_on == 1.0f)
    {
        Speed = ParamAdjust(g_FX_param1, 0.0f, 4.0f);
    }
    
    float2 texcoord = input.TexCoord;
    float2 Middle = float2(0.5f, 0.5f);
    float2 texcoord2 = texcoord - Middle;
    
    float speed_1 = sin(Speed * time);
    float speed_2 = sin(Speed * time * 10.0f);
    
    float x1 = pow(speed_1 / 2.0f, 2.0f) * 4.0f;
    float x2 = (speed_2 + 1.0f) / 2.0f;
    
    const float minBlur = 0.0f;
    const float maxBlur = 0.3f;
    float alpha = smoothstep(0.0f, 1.0f, x1) * x2;
    float timeQ = lerp(minBlur, maxBlur, alpha);
    
    const int samples = 25;
    float q = 0;
    float2 texcoord3 = float2(0.0f, 0.0f);
    float4 colTex = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    
    for (int i = 0; i <= samples; i++)
    {
        q = float(i) / float(samples);
        texcoord3 = texcoord - texcoord2 * timeQ * q;
        colTex = g_Texture2D.Sample(g_SamplerState, texcoord3);
        color += colTex / float(samples);
    }

    color += alpha / 2.0f;
        
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}