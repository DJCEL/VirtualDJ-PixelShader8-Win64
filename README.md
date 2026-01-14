![logo](https://github.com/djcel/VirtualDJ-PixelShader8-Win64/blob/main/PixelShader8_website.JPG?raw=true "")
# VirtualDJ-PixelShader8-Win64

DLL compilation (64bit):
- Output filepath: C:\Users\\{your_username}\AppData\Local\VirtualDJ\Plugins64\VideoEffect\PixelShader8.dll

HLSL compilation:
- Entrypoint Name: ps_main
- Shader Type: Pixel Shader (/ps)
- Shader Model: Shader Model 5.0 (/5.0)
- Output filepath: (.cso files) in the 'Shaders' subfolder as they are included in Resources (Plugin.rc).

Examples of Pixel Shaders are in the 'Shaders' subfolder.

Right click on 'Plugin.rc' file and select 'View Code' to add shaders in Resources.

If you know GLSL and want to use the syntax, you can also define:
- #define vec2 float2
- #define vec3 float3
- #define vec4 float4
- #define mix lerp
- #define fract frac
