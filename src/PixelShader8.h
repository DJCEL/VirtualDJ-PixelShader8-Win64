#ifndef PIXELSHADER8_H
#define PIXELSHADER8_H


#include "vdjVideo8.h"
#include <stdio.h>
#include <d3d11.h>
#include <d3dcompiler.h> // if we want to compile the shader with the code

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "d3dcompiler.lib")

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
	void OnResizeVideo();
	void OnSlider(int id);
	HRESULT ReadResource(const WCHAR* resourceType, const WCHAR* resourceName, SIZE_T* size, LPVOID* data);

	HRESULT Initialize_D3D11(ID3D11Device* pDevice);
	void Release_D3D11();
	HRESULT Rendering_D3D11(ID3D11Device* pDevice, ID3D11DeviceContext* pDeviceContext, ID3D11RenderTargetView* pRenderTargetView, ID3D11ShaderResourceView* pTextureView, TVertex8* pVertices);
	HRESULT Create_PixelShader_D3D11(ID3D11Device* pDevice);
	HRESULT Create_PixelShaderFromCSOFile_D3D11(ID3D11Device* pDevice, const WCHAR* pShaderFilepath);
	HRESULT Create_PixelShaderFromHLSLFile_D3D11(ID3D11Device* pDevice, const WCHAR* pShaderFilepath);
	HRESULT Create_PixelShaderFromHeaderFile_D3D11(ID3D11Device* pDevice, const char* PixelShaderData);
	HRESULT Create_PixelShaderFromResourceCSOFile_D3D11(ID3D11Device* pDevice, const WCHAR* resourceType, const WCHAR* resourceName);
	HRESULT Create_VertexBufferDynamic_D3D11(ID3D11Device* pDevice);
	HRESULT Update_VertexBufferDynamic_D3D11(ID3D11DeviceContext* ctx);
	HRESULT Update_Vertices_D3D11();
	HRESULT GetInfoFromShaderResourceView(ID3D11ShaderResourceView* pShaderResourceView);
	HRESULT GetInfoFromRenderTargetView(ID3D11RenderTargetView* pRenderTargetView);

	
	ID3D11Device* pD3DDevice;
	ID3D11DeviceContext* pD3DDeviceContext;
	ID3D11RenderTargetView* pD3DRenderTargetView;
	ID3D11Buffer* pNewVertexBuffer;
	ID3D11PixelShader* pPixelShader;
	
	TLVERTEX pNewVertices[6];
	UINT m_VertexCount;
	bool DirectX_On;
	int m_Width;
	int m_Height;
	float SliderValue[2];
	float alpha;
	int FX;
	int current_FX;

	typedef enum _ID_Interface
	{
		ID_INIT,
		ID_SLIDER_1,
		ID_SLIDER_2
	} ID_Interface;

	#ifndef SAFE_RELEASE
	#define SAFE_RELEASE(x) { if (x!=nullptr) { x->Release(); x=nullptr; } }
	#endif

};

#endif
