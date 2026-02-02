![logo](https://github.com/djcel/VirtualDJ-PixelShader8-Win64/blob/main/PixelShader8_website.JPG?raw=true "")
# VirtualDJ-PixelShader8-Win64

DLL compilation (64bit):
- Output filepath: C:\Users\\{your_username}\AppData\Local\VirtualDJ\Plugins64\VideoEffect\PixelShader8.dll

HLSL compilation:
- Entrypoint Name: ps_main
- Shader Type: Pixel Shader (/ps)
- Shader Model: Shader Model 5.0 (/5.0)
- Output filepath: "..\src\Shaders\%(Filename).cso"   

Examples of Pixel Shaders are in the 'Shaders' subfolder.

During compilation the .cso files are saved in the '..\src\Shaders' subfolder and they are then included in the Resources (via Plugin.rc). To add a new one, right click on the 'Plugin.rc' file and select 'View Code'.
