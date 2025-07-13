#pragma once

const char* PixelShaderSrcData = R"(
		Texture2D g_Texture2D : register(t0);
		SamplerState g_SamplerState : register(s0);

		struct PS_INPUT
		{
			float4 Position : SV_Position;
			float4 Color : COLOR0;
			float2 TexCoord : TEXCOORD0;
		};

		struct PS_OUTPUT
		{
			float4 Color : SV_TARGET;
		};

		PS_OUTPUT ps_main(PS_INPUT input)
		{
			PS_OUTPUT output;
			
			float2 texcoord = input.TexCoord;
			output.Color = g_Texture2D.Sample(g_SamplerState, texcoord);
			output.Color = output.Color * input.Color;
			
			return output;
		}

		)";