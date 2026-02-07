//#pragma once
#ifndef PIXELSHADER8_H
#define PIXELSHADER8_H


#include "vdjVideo8.h"
#include <stdio.h>
#include <chrono>
#include <d3d11.h>
//#include <d3dcompiler.h> // if we want to compile the shader with the code by using D3DCompileFromFile()

#pragma comment(lib, "d3d11.lib")
//#pragma comment(lib, "d3dcompiler.lib")

//////////////////////////////////////////////////////////////////////////
// Class definition
//////////////////////////////////////////////////////////////////////////
class CPixelShader8 : public IVdjPluginVideoFx8
{
public:
	CPixelShader8();
	~CPixelShader8();
	HRESULT VDJ_API OnLoad();
	HRESULT VDJ_API OnGetPluginInfo(TVdjPluginInfo8 *info);
	ULONG   VDJ_API Release();
	HRESULT VDJ_API OnParameter(int id);
	HRESULT VDJ_API OnGetParameterString(int id, char* outParam, int outParamSize);
	HRESULT VDJ_API OnDeviceInit();
	HRESULT VDJ_API OnDeviceClose();
	HRESULT VDJ_API OnDraw();
	HRESULT VDJ_API OnStart();
	HRESULT VDJ_API OnStop();

private:
	struct D3DXPOSITION
	{
		float x;
		float y;
		float z;
	};
	struct D3DXCOLOR
	{
	public:
		D3DXCOLOR() = default;
		D3DXCOLOR(FLOAT r, FLOAT g, FLOAT b, FLOAT a)
		{
			this->r = r;
			this->g = g;
			this->b = b;
			this->a = a;
		}

		operator FLOAT* ()
		{
			return &r;
		}

		FLOAT r, g, b, a;
	};
	struct D3DXTEXCOORD
	{
		float tu;
		float tv;
	};

	struct TLVERTEX
	{
		D3DXPOSITION position;
		D3DXCOLOR color;
		D3DXTEXCOORD texture;
	};

	struct InfoTexture2D
	{
		UINT Width;
		UINT Height;
		DXGI_FORMAT Format;
	};

	__declspec(align(16))
	struct PS_CONSTANTBUFFER
	{
		float FX_Time; // shader playback time (in seconds), elapsed time value.
		float FX_Width;
		float FX_Height;
		float FX_params_on; // if 1.0f, use the customized FX_paramX, otherwise the plugin uses the default ones defined in the shader
		float FX_param1; // 1st param (slider from 0.0f to 1.0f)
		float FX_param2; // 2nd param (slider from 0.0f to 1.0f)
		float FX_param3; // 3rd param (slider from 0.0f to 1.0f)
		float FX_param4; // 4th param (slider from 0.0f to 1.0f)
		float FX_param5; // 5th param (slider from 0.0f to 1.0f)
	};

	void OnResizeVideo();
	void OnButton(int id);
	float ParamAdjust(float value, float ValMin, float ValMax);
	void OnSlider(int id);
	HRESULT ReadResource(const WCHAR* resourceType, const WCHAR* resourceName, SIZE_T* size, LPVOID* data);
	bool Get_DllFolderPath_and_DllFilename();
	void Display_FX_Name(char* outParam, int outParamSize);
	long long GetCurrentTimeMilliseconds();
	void setShaderPlaybackTime();

	// Customize params for each shader
	int	Get_FX_Params_Number();
	void Display_FX_Param1(char* outParam, int outParamSize, float value);
	void Display_FX_Param2(char* outParam, int outParamSize, float value);
	void Display_FX_Param3(char* outParam, int outParamSize, float value);
	void Display_FX_Param4(char* outParam, int outParamSize, float value);
	void Display_FX_Param5(char* outParam, int outParamSize, float value);


	HRESULT Initialize_D3D11(ID3D11Device* pDevice);
	void Release_D3D11();
	HRESULT Rendering_D3D11(ID3D11Device* pDevice, ID3D11DeviceContext* pDeviceContext, ID3D11RenderTargetView* pRenderTargetView, ID3D11ShaderResourceView* pTextureView, TVertex8* pVertices);
	HRESULT Create_PixelShader_D3D11(ID3D11Device* pDevice);
	//HRESULT Create_PixelShaderFromHLSLFile_D3D11(ID3D11Device* pDevice, const WCHAR* pShaderFilepath);
	HRESULT Create_PixelShaderFromResourceCSOFile_D3D11(ID3D11Device* pDevice, const WCHAR* resourceType, const WCHAR* resourceName);
	HRESULT Create_VertexBufferDynamic_D3D11(ID3D11Device* pDevice);
	HRESULT Update_VertexBufferDynamic_D3D11(ID3D11DeviceContext* ctx);
	HRESULT Update_Vertices_D3D11();
	HRESULT Create_PSConstantBufferDynamic_D3D11(ID3D11Device* pDevice);
	HRESULT Update_PSConstantBufferDynamic_D3D11(ID3D11DeviceContext* ctx);
	HRESULT Update_PSConstantBufferData_D3D11();
	HRESULT GetInfoFromShaderResourceView(ID3D11ShaderResourceView* pShaderResourceView, InfoTexture2D* info);
	HRESULT GetInfoFromRenderTargetView(ID3D11RenderTargetView* pRenderTargetView, InfoTexture2D* info);

	
	ID3D11Device* pD3DDevice;
	ID3D11DeviceContext* pD3DDeviceContext;
	ID3D11RenderTargetView* pD3DRenderTargetView;
	ID3D11Buffer* pNewVertexBuffer;
	ID3D11PixelShader* pPixelShader;
	ID3D11Buffer* pPSConstantBuffer;
	
	PS_CONSTANTBUFFER m_PSConstantBufferData;

	WCHAR m_DllFolderPath[2000]; // The DLL folder path
	WCHAR m_DllFilename[50];	// The DLL filename
	TLVERTEX pNewVertices[6];
	UINT m_VertexCount;
	bool m_DirectX_On;
	int m_Width;
	int m_Height;
	long long m_TimeInit;
	float m_Time;
	float m_SliderValue[7];
	WCHAR m_FX_Name[150];
	int m_FX_params_on;
	float m_FX_param[5];
	float m_alpha;
	UINT m_FX;
	UINT m_current_FX;
	int m_ButtonLeft;
	int m_ButtonRight;

	typedef enum _ID_Interface
	{
		ID_INIT,
		ID_SLIDER_1,
		ID_SLIDER_2,
		ID_SLIDER_3,
		ID_SLIDER_4,
		ID_SLIDER_5,
		ID_SLIDER_6,
		ID_SLIDER_7,
		ID_SLIDER_MAX,
		ID_SWITCH_1,
		ID_BUTTON_1,
		ID_BUTTON_2,
	} ID_Interface;

	#ifndef SAFE_RELEASE
	#define SAFE_RELEASE(x) { if (x!=nullptr) { x->Release(); x=nullptr; } }
	#endif

	// Number of FX available :
	static const UINT NUMBER_FX = 18;

	// Names of FX available :
	const WCHAR* m_FXList[NUMBER_FX] = {
		L"GrayScale",
		L"GBR",
		L"HighContrast",
		L"Negative",
		L"HorizontalMirror",
		L"VerticalMirror",
		L"Rotate180",
		L"Rotate",
		L"PixelsHide",
		L"CenterBlur",
		L"ColorDistorsion",
		L"Sepia",
		L"Polarize",
		L"Mask",
		L"ColorSpace",
		L"Wave",
		L"Ripple",
		L"EdgeDetection",
	};
};

#endif
 /* PIXELSHADER8_H */