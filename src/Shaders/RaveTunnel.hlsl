////////////////////////////////
// File: RaveTunnel.hlsl
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
float smoothWave(float x)
{
    // Improved Perlin-like noise function for smoother waves
    return smoothstep(-1.0, 1.0, sin(x));
}
//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT ps_main(PS_INPUT input)
{
    float time = g_FX_Beats_on ? g_FX_SongPosBeats : g_FX_Time;
    
    float Speed = 1.0f;
   
    if (g_FX_params_on)
    {
        Speed = ParamAdjust(g_FX_param1, 0.0f, 5.0f);
    }
    
    float time_adjusted = time * Speed;
    
    float2 texcoord = input.TexCoord;
    
    float2 center = float2(0.5f, 0.5f);
    float2 p = texcoord - center;
    float dist = length(p);
    float angle = atan2(p.y, p.x);
    
    // Create multi-layered wave patterns for more complex visuals
    float wave1 = sin(dist * 20.0 - time_adjusted * 6.0 + angle * 5.0);
    float wave2 = sin(dist * 15.0 - time_adjusted * 4.0 + angle * 3.0) * 0.5;
    float wave3 = cos(dist * 25.0 - time_adjusted * 8.0 + angle * 7.0) * 0.3;
    float pattern = wave1 + wave2 + wave3;
    
    // Smooth the pattern for better visual quality
    float smoothPattern = smoothstep(-2.0, 2.0, pattern);
    float v = abs(pattern) * 1.2; // Enhance contrast
    v = clamp(v, 0.0, 1.0);
    
    // Create mask with smoother falloff
    float4 mask = float4(v, v * 0.9, v * 0.8, 1.0f);
    
    // Apply directional wave offset to texture
    float waveOffset = pattern * 0.15;
    float2 waveDir = normalize(p);
    float2 texcoord2 = texcoord + waveDir * waveOffset;
    
    // Add perpendicular offset for richer distortion
    float2 perpDir = float2(-waveDir.y, waveDir.x);
    texcoord2 += perpDir * sin(time_adjusted * 3.0 + angle * 4.0) * 0.08;
    
    // Sample texture with enhanced distortion
    float4 texColor = g_Texture2D.Sample(g_SamplerState, texcoord2);
    
    // Add color vibrance and enhance saturation
    float luminance = dot(texColor.rgb, float3(0.299, 0.587, 0.114));
    float3 colorEnhanced = lerp(float3(luminance, luminance, luminance), texColor.rgb, 1.3);
    texColor.rgb = clamp(colorEnhanced, 0.0, 1.0);
    
    float4 color = texColor * mask;
      
    PS_OUTPUT output;
    output.Color = color;
    output.Color = output.Color * input.Color;
    return output;
}
