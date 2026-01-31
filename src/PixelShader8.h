#ifndef PIXELSHADER8_H
#define PIXELSHADER8_H


#include "vdjVideo8.h"
#include <stdio.h>
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
		float FX_param1;
		float FX_param2;
		float FX_param3;
	};

	void OnResizeVideo();
	void OnButton(int id);
	void OnSlider(int id);
	HRESULT ReadResource(const WCHAR* resourceType, const WCHAR* resourceName, SIZE_T* size, LPVOID* data);
	const WCHAR* GetShaderName(int type);

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

	TLVERTEX pNewVertices[6];
	UINT m_VertexCount;
	bool m_DirectX_On;
	int m_Width;
	int m_Height;
	float m_SliderValue[5];
	float m_alpha;
	UINT m_FX;
	UINT m_current_FX;
	int m_ButtonLeft;
	int m_ButtonRight;
	float m_FX_param1;
	float m_FX_param2;
	float m_FX_param3;

	typedef enum _ID_Interface
	{
		ID_INIT,
		ID_SLIDER_1,
		ID_SLIDER_2,
		ID_SLIDER_3,
		ID_SLIDER_4,
		ID_SLIDER_5,
		ID_SLIDER_MAX,
		ID_BUTTON_1,
		ID_BUTTON_2,
	} ID_Interface;

	#ifndef SAFE_RELEASE
	#define SAFE_RELEASE(x) { if (x!=nullptr) { x->Release(); x=nullptr; } }
	#endif

	// Number of FX available :
	static const UINT NUMBER_FX = 12;

	// Names of FX available :
	const WCHAR* m_FXList[NUMBER_FX] = {
		L"GrayScale",
		L"GBR",
		L"HighContrast",
		L"Negative",
		L"HorizontalMirror",
		L"Rotate180",
		L"PixelsHide",
		L"CenterBlur",
		L"ColorDistorsion",
		L"Sepia",
		L"Polarize",
		L"ColorSpace"
	};
};

#endif
