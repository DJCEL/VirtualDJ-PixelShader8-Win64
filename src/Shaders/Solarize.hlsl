////////////////////////////////
// File: Solarize.hlsl
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

    float Threshold = 0.5f; // seuil d'inversion
    float Softness = 0.02f; // largeur de la transition (0 = coupure nette)
    int UseLuma = 0; // 0 = par canal RGB, 1 = selon la luminance
    int InvBelow = 0; // 0 = inverse au-dessus du seuil, 1 = en dessous
    float Sweep = 0.0f; // amplitude du balayage automatique du seuil

    if (g_FX_params_on == 1.0f)
    {
        Threshold = ParamAdjust(g_FX_param1, 0.0f, 1.0f);
        Softness = ParamAdjust(g_FX_param2, 0.0f, 0.5f);
        UseLuma = int(round(ParamAdjust(g_FX_param3, 0.0f, 1.0f)));
        InvBelow = int(round(ParamAdjust(g_FX_param4, 0.0f, 1.0f)));
        Sweep = ParamAdjust(g_FX_param5, 0.0f, 0.5f);
    }

    float2 texcoord = input.TexCoord;
    float4 src = g_Texture2D.Sample(g_SamplerState, texcoord);
    
    // le seuil oscille doucement : un cycle complet toutes les 4 unités de temps
    float thr = saturate(Threshold + Sweep * sin(time * 1.5708f));

    // valeur testée contre le seuil : luminance globale ou chaque canal
    float3 c = src.rgb;
    float luma = dot(c, float3(0.299f, 0.587f, 0.114f));
    float3 v = (UseLuma == 1) ? float3(luma, luma, luma) : c;

    // masque 0..1 : 1 là où l'on inverse (transition douce autour du seuil)
    float eps = max(Softness, 0.0001f);
    float3 mask = smoothstep(thr - eps, thr + eps, v);
    if (InvBelow == 1)
        mask = 1.0f - mask;

    float3 result = lerp(c, 1.0f - c, mask);
    float4 color = float4(result, src.a);
    
    PS_OUTPUT output;
    output.Color = color;
    output.Color *= input.Color;
    return output;
}
