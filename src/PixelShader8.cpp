#include "PixelShader8.h"


//------------------------------------------------------------------------------------------
CPixelShader8::CPixelShader8()
{
	pD3DDevice = nullptr; 
	pD3DDeviceContext = nullptr;
	pD3DRenderTargetView = nullptr;
	pNewVertexBuffer = nullptr;
	pPixelShader = nullptr;
	pPSConstantBuffer = nullptr;
	ZeroMemory(pNewVertices, 6 * sizeof(TVertex8));
	ZeroMemory(m_SliderValue, 5 * sizeof(float));
	ZeroMemory(&m_PSConstantBufferData, sizeof(PS_CONSTANTBUFFER));
	m_DirectX_On = false;
	m_Width = 0;
	m_Height = 0;
	m_VertexCount = 0;
	m_alpha = 1.0f;
	m_FX = 0;
	m_current_FX = 0;
	m_FX_param1 = 0.0f;
	m_FX_param2 = 0.0f;
	m_FX_param3 = 0.0f;
}
//------------------------------------------------------------------------------------------
CPixelShader8::~CPixelShader8()
{

}
//------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnLoad()
{
	HRESULT hr = S_FALSE;

	hr = DeclareParameterSlider(&m_SliderValue[0], ID_SLIDER_1, "Wet/Dry", "W/D", 1.0f);
	hr = DeclareParameterSlider(&m_SliderValue[1], ID_SLIDER_2, "FX Select", "FX", 0.0f);
	hr = DeclareParameterSlider(&m_SliderValue[2], ID_SLIDER_3, "FX Param1", "FX_P1", 0.5f);
	hr = DeclareParameterSlider(&m_SliderValue[3], ID_SLIDER_4, "FX Param2", "FX_P2", 0.10f);
	hr = DeclareParameterSlider(&m_SliderValue[4], ID_SLIDER_5, "FX Param3", "FX_P3", 0.10f);

	hr = OnParameter(ID_INIT);
	return S_OK;
}
//------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnGetPluginInfo(TVdjPluginInfo8 *info)
{
	info->Author = "djcel";
	info->PluginName = "PixelShader8";
	info->Description = "Use of pixel shader.";
	info->Flags = 0x00; // VDJFLAG_VIDEO_OUTPUTRESOLUTION | VDJFLAG_VIDEO_OUTPUTASPECTRATIO;
	info->Version = "1.5 (64-bit)";

	return S_OK;
}
//------------------------------------------------------------------------------------------
ULONG VDJ_API CPixelShader8::Release()
{
	delete this;
	return 0;
}
//------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnParameter(int id)
{
	if (id == ID_INIT)
	{
		for (int i = ID_SLIDER_1; i <= ID_SLIDER_5; i++) OnSlider(i);
	}
	else
	{
		OnSlider(id);
	}
	
	return S_OK;
}

//------------------------------------------------------------------------------------------
void CPixelShader8::OnSlider(int id)
{
	switch (id)
	{
		case ID_SLIDER_1:
			m_alpha = m_SliderValue[0];
			break;

		case ID_SLIDER_2:
			m_FX = (int)(m_SliderValue[1] * float(MAX_FX - 1)); // Integer from 0 to (MAX_FX - 1)
			break;

		case ID_SLIDER_3:
			m_FX_param1 = m_SliderValue[2] * 20.0f;
			break;

		case ID_SLIDER_4:
			m_FX_param2 = m_SliderValue[3] * 2.0f;
			break;

		case ID_SLIDER_5:
			m_FX_param3 = m_SliderValue[4] * 5.0f;
			break;
	}
}
//-------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnGetParameterString(int id, char* outParam, int outParamSize)
{
	const WCHAR* FXName = m_FXList[m_FX];

	switch (id)
	{
		case ID_SLIDER_1:
			sprintf_s(outParam, outParamSize, "%.0f%%", m_alpha * 100);
			break;

		case ID_SLIDER_2:
			if (FXName == nullptr)
			{
				sprintf_s(outParam, outParamSize, "Error in the FX list.");
			}
			else
			{
				char FXNameChar[150] = { 0 };
				int size_needed = WideCharToMultiByte(CP_UTF8, 0, FXName, -1, NULL, 0, NULL, NULL);
				int max_size = outParamSize / sizeof(char);
				if (size_needed > 0 && size_needed <= max_size)
				{
					int res = WideCharToMultiByte(CP_UTF8, 0, FXName, -1, FXNameChar, size_needed, NULL, NULL);
					if (res >= 0)
					{
						sprintf_s(outParam, outParamSize, FXNameChar);
					}
					else
					{
						sprintf_s(outParam, outParamSize, "Error FXName");
					}
				}
				else
				{
					sprintf_s(outParam, outParamSize, "FXName too long");
				}
			}
			break;

		case ID_SLIDER_3:
			sprintf_s(outParam, outParamSize, "%.2f", m_FX_param1);
			break;

		case ID_SLIDER_4:
			sprintf_s(outParam, outParamSize, "%.2f", m_FX_param2);
			break;

		case ID_SLIDER_5:
			sprintf_s(outParam, outParamSize, "%.2f", m_FX_param3);
			break;
	}

	return S_OK;
}
//-------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnDeviceInit()
{
	HRESULT hr = S_FALSE;

	m_DirectX_On = true;
	m_Width = width;
	m_Height = height;
	m_current_FX = m_FX;

	hr = GetDevice(VdjVideoEngineDirectX11, (void**)  &pD3DDevice);
	if(hr!=S_OK || pD3DDevice==NULL) return E_FAIL;

	hr = Initialize_D3D11(pD3DDevice);

	return S_OK;
}
//-------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnDeviceClose()
{
	Release_D3D11();
	SAFE_RELEASE(pD3DRenderTargetView);
	SAFE_RELEASE(pD3DDeviceContext);
	m_DirectX_On = false;
	
	return S_OK;
}
//-------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnStart() 
{
	HRESULT hr = S_FALSE;

	// Check if we need to update the pixel shader
	if (m_current_FX != m_FX && pD3DDevice != nullptr && pPixelShader != nullptr)
	{
		SAFE_RELEASE(pPixelShader);
		hr = Create_PixelShader_D3D11(pD3DDevice);
		if (hr != S_OK) return S_FALSE;
		m_current_FX = m_FX;
	}

	return S_OK;
}
//-------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnStop() 
{
	return S_OK;
}
//-------------------------------------------------------------------------------------------
HRESULT VDJ_API CPixelShader8::OnDraw()
{
	HRESULT hr = S_FALSE;
	ID3D11ShaderResourceView *pTexture = nullptr;
	TVertex8* vertices = nullptr;

	if (m_Width != width || m_Height != height)
	{
		OnResizeVideo();
	}

	if (!pD3DDevice) return S_FALSE;

	pD3DDevice->GetImmediateContext(&pD3DDeviceContext);
	if (!pD3DDeviceContext) return S_FALSE;

	pD3DDeviceContext->OMGetRenderTargets(1, &pD3DRenderTargetView, nullptr);
	if (!pD3DRenderTargetView) return S_FALSE;

	// We get current texture and vertices
	hr = GetTexture(VdjVideoEngineDirectX11, (void**)&pTexture, &vertices);
	if (hr != S_OK) return S_FALSE;

	hr = Rendering_D3D11(pD3DDevice, pD3DDeviceContext, pD3DRenderTargetView, pTexture, vertices);
	if (hr != S_OK) return S_FALSE;

	return S_OK;
}
//-----------------------------------------------------------------------
void CPixelShader8::OnResizeVideo()
{
	m_Width = width;
	m_Height = height;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Initialize_D3D11(ID3D11Device* pDevice)
{
	HRESULT hr = S_FALSE;

	hr = Create_VertexBufferDynamic_D3D11(pDevice);
	if (hr != S_OK) return S_FALSE;

	hr = Create_PixelShader_D3D11(pDevice);
	if (hr != S_OK) return S_FALSE;

	hr = Create_PSConstantBufferDynamic_D3D11(pDevice);
	if (hr != S_OK) return S_FALSE;

	return S_OK;
}
//-----------------------------------------------------------------------
void CPixelShader8::Release_D3D11()
{
	SAFE_RELEASE(pNewVertexBuffer);
	SAFE_RELEASE(pPixelShader);
	SAFE_RELEASE(pPSConstantBuffer);
}
// -----------------------------------------------------------------------
HRESULT CPixelShader8::Rendering_D3D11(ID3D11Device* pDevice, ID3D11DeviceContext* pDeviceContext, ID3D11RenderTargetView* pRenderTargetView, ID3D11ShaderResourceView* pTextureView, TVertex8* pVertices)
{
	HRESULT hr = S_FALSE;

#ifdef _DEBUG
	InfoTexture2D InfoRTV = {};
	InfoTexture2D InfoSRV = {};
	hr = GetInfoFromRenderTargetView(pRenderTargetView, &InfoRTV);
	hr = GetInfoFromShaderResourceView(pTextureView, &InfoSRV);
#endif


	// Check if we need to update the pixel shader
	if (m_current_FX != m_FX)
	{
		SAFE_RELEASE(pPixelShader);
		hr = Create_PixelShader_D3D11(pD3DDevice);
		if (hr != S_OK) return S_FALSE;
		m_current_FX = m_FX;
	}


	hr = DrawDeck();
	if (hr != S_OK) return S_FALSE;

	if (pRenderTargetView)
	{
		//FLOAT backgroundColor[4] = { 0.0f, 0.0f, 0.0f, 1.0f };
		//pDeviceContext->ClearRenderTargetView(pRenderTargetView, backgroundColor);
		//pDeviceContext->OMSetRenderTargets(1, &pRenderTargetView, nullptr);
	}

	hr = Update_VertexBufferDynamic_D3D11(pDeviceContext);
	if (hr != S_OK) return S_FALSE;

	hr = Update_PSConstantBufferDynamic_D3D11(pDeviceContext);
	if (hr != S_OK) return S_FALSE;

	if (pPixelShader)
	{
		pDeviceContext->PSSetShader(pPixelShader, nullptr, 0);
	}

	if (pPSConstantBuffer)
	{
		pDeviceContext->PSSetConstantBuffers(0, 1, &pPSConstantBuffer);
	}
	
	if (pTextureView)
	{
		pDeviceContext->PSSetShaderResources(0, 1, &pTextureView);
	}


	if (pNewVertexBuffer)
	{
		UINT m_VertexStride = sizeof(TLVERTEX);
		UINT m_VertexOffset = 0;
		pDeviceContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
		pDeviceContext->IASetVertexBuffers(0, 1, &pNewVertexBuffer, &m_VertexStride, &m_VertexOffset);
	}
	
	pDeviceContext->Draw(m_VertexCount, 0);


	return S_OK;
}
// ---------------------------------------------------------------------- -
HRESULT CPixelShader8::Create_VertexBufferDynamic_D3D11(ID3D11Device* pDevice)
{
	HRESULT hr = S_FALSE;

	if (!pDevice) return E_FAIL;

	// Set the number of vertices in the vertex array.
	m_VertexCount = 6; // = ARRAYSIZE(pNewVertices);
	
	// Fill in a buffer description.
	D3D11_BUFFER_DESC VertexBufferDesc;
	ZeroMemory(&VertexBufferDesc, sizeof(VertexBufferDesc));
	VertexBufferDesc.Usage = D3D11_USAGE_DYNAMIC;   // CPU_Access=Write_Only & GPU_Access=Read_Only
	VertexBufferDesc.ByteWidth = sizeof(TLVERTEX) * m_VertexCount;
	VertexBufferDesc.BindFlags = D3D11_BIND_VERTEX_BUFFER; // Use as vertex buffer  // or D3D11_BIND_INDEX_BUFFER
	VertexBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE; // Allow CPU to write in buffer
	VertexBufferDesc.MiscFlags = 0;

	hr = pDevice->CreateBuffer(&VertexBufferDesc, NULL, &pNewVertexBuffer);
	if (hr != S_OK || !pNewVertexBuffer) return S_FALSE;

	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Update_VertexBufferDynamic_D3D11(ID3D11DeviceContext* ctx)
{
	HRESULT hr = S_FALSE;

	if (!ctx) return S_FALSE;
	if (!pNewVertexBuffer) return S_FALSE;

	D3D11_MAPPED_SUBRESOURCE MappedSubResource;
	ZeroMemory(&MappedSubResource, sizeof(D3D11_MAPPED_SUBRESOURCE));


	hr = ctx->Map(pNewVertexBuffer, NULL, D3D11_MAP_WRITE_DISCARD, 0, &MappedSubResource);
	if (hr != S_OK) return S_FALSE;

	hr = Update_Vertices_D3D11();

	memcpy(MappedSubResource.pData, pNewVertices, m_VertexCount * sizeof(TLVERTEX));

	ctx->Unmap(pNewVertexBuffer, NULL);

	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Update_Vertices_D3D11()
{
	float frameWidth = (float) m_Width;
	float frameHeight = (float) m_Height;

	D3DXPOSITION P1 = { 0.0f, 0.0f, 0.0f }, // Top Left
		P2 = { 0.0f, frameHeight, 0.0f }, // Bottom Left
		P3 = { frameWidth, 0.0f, 0.0f }, // Top Right
		P4 = { frameWidth, frameHeight, 0.0f }; // Bottom Right
	D3DXCOLOR color_vertex = D3DXCOLOR(1.0f, 1.0f, 1.0f, m_alpha); // White color with alpha layer
	D3DXTEXCOORD T1 = { 0.0f , 0.0f }, T2 = { 0.0f , 1.0f }, T3 = { 1.0f , 0.0f }, T4 = { 1.0f , 1.0f };

	// Triangle n°1 (Bottom Right)
	pNewVertices[0] = { P3 , color_vertex , T3 };
	pNewVertices[1] = { P4 , color_vertex , T4 };
	pNewVertices[2] = { P2 , color_vertex , T2 };

	// Triangle n°2 (Top Left)
	pNewVertices[3] = { P2 , color_vertex , T2 };
	pNewVertices[4] = { P1 , color_vertex , T1 };
	pNewVertices[5] = { P3 , color_vertex , T3 };


	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Create_PixelShader_D3D11(ID3D11Device* pDevice)
{
	HRESULT hr = S_FALSE;
	
	const WCHAR* pShaderHLSLFilepath = GetShaderName(1);
	const WCHAR* pShaderCSOFilepath = GetShaderName(2);
	const WCHAR* resourceName = GetShaderName(3);
	const WCHAR* resourceType = RT_RCDATA;

	SAFE_RELEASE(pPixelShader);

	hr = Create_PixelShaderFromResourceCSOFile_D3D11(pDevice, resourceType, resourceName);
	//hr = Create_PixelShaderFromHLSLFile_D3D11(pDevice, pShaderHLSLFilepath);

	return hr;
}
//-----------------------------------------------------------------------
const WCHAR* CPixelShader8::GetShaderName(int type)
{
	static WCHAR ShaderName[150] = L"";
	WCHAR FXNameUpper[150] = L"";

	const WCHAR* FXName = m_FXList[m_FX];

	if (FXName == nullptr) return L"";

	wcsncpy_s(FXNameUpper, FXName, _TRUNCATE);
	CharUpperW(FXNameUpper);


	switch (type)
	{	
		case 1:
			swprintf_s(ShaderName, 150, L"%s.hlsl", FXName);
			break;

		case 2:
			swprintf_s(ShaderName, 150, L"%s.cso", FXName);
			break;

		case 3:
			swprintf_s(ShaderName, 150, L"%s_CSO", FXNameUpper);
			break;

		default:
			swprintf_s(ShaderName, 150, L"");
			break;
	}

	return ShaderName;
}
//-----------------------------------------------------------------------
/*
HRESULT CPixelShader8::Create_PixelShaderFromHLSLFile_D3D11(ID3D11Device* pDevice, const WCHAR* pShaderFilepath)
{
	HRESULT hr = S_FALSE;
	ID3DBlob* pPixelShaderBlob = nullptr;
	ID3DBlob* errorBlob = nullptr;

	hr = D3DCompileFromFile(pShaderFilepath, nullptr, nullptr, "ps_main", "ps_5_0", 0, 0, &pPixelShaderBlob, &errorBlob);
	if (FAILED(hr))
	{
		const char* errorString = NULL;
		if (hr == HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND))
		{
			errorString = "Could not compile Pixel-Shader. HLSL file not found.";
		}
		else if (errorBlob)
		{
			errorString = (const char*) errorBlob->GetBufferPointer();
			SAFE_RELEASE(errorBlob);
		}
		MessageBoxA(NULL, errorString, "PixelShader8", MB_ICONERROR | MB_OK);
		return hr;
	}

	LPVOID PixelShaderBytecode = pPixelShaderBlob->GetBufferPointer();
	SIZE_T PixelShaderBytecodeLength = pPixelShaderBlob->GetBufferSize();

	hr = pDevice->CreatePixelShader(PixelShaderBytecode, PixelShaderBytecodeLength, nullptr, &pPixelShader);

	SAFE_RELEASE(pPixelShaderBlob);

	return hr;
}
*/
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Create_PixelShaderFromResourceCSOFile_D3D11(ID3D11Device* pDevice, const WCHAR* resourceType, const WCHAR* resourceName)
{
	HRESULT hr = S_FALSE;

	void* pShaderBytecode = nullptr;
	SIZE_T BytecodeLength = 0;

	hr = ReadResource(resourceType, resourceName, &BytecodeLength, &pShaderBytecode);
	if (hr != S_OK) return S_FALSE;
	
	hr = pDevice->CreatePixelShader(pShaderBytecode, BytecodeLength, nullptr, &pPixelShader);

	return hr;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Create_PSConstantBufferDynamic_D3D11(ID3D11Device* pDevice)
{
	HRESULT hr = S_FALSE;

	if (!pDevice) return E_FAIL;

	UINT SIZEOF_PS_CONSTANTBUFFER = sizeof(PS_CONSTANTBUFFER);
	UINT CB_BYTEWIDTH = SIZEOF_PS_CONSTANTBUFFER + 0xf & 0xfffffff0;

	D3D11_BUFFER_DESC ConstantBufferDesc = {};
	ConstantBufferDesc.Usage = D3D11_USAGE_DYNAMIC;  // CPU_Access=Write_Only & GPU_Access=Read_Only
	ConstantBufferDesc.ByteWidth = CB_BYTEWIDTH;
	ConstantBufferDesc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
	ConstantBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;  // Allow CPU to write in buffer
	ConstantBufferDesc.MiscFlags = 0;

	// Create the constant buffer to send to the cbuffer in hlsl file
	hr = pDevice->CreateBuffer(&ConstantBufferDesc, nullptr, &pPSConstantBuffer);
	if (hr != S_OK || !pPSConstantBuffer) return S_FALSE;

	return hr;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Update_PSConstantBufferDynamic_D3D11(ID3D11DeviceContext* ctx)
{
	HRESULT hr = S_FALSE;

	if (!ctx) return S_FALSE;
	if (!pPSConstantBuffer) return S_FALSE;

	hr = Update_PSConstantBufferData_D3D11();

	D3D11_MAPPED_SUBRESOURCE MappedSubResource;
	ZeroMemory(&MappedSubResource, sizeof(D3D11_MAPPED_SUBRESOURCE));

	hr = ctx->Map(pPSConstantBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &MappedSubResource);
	if (hr != S_OK) return S_FALSE;

	memcpy(MappedSubResource.pData, &m_PSConstantBufferData, sizeof(PS_CONSTANTBUFFER));

	ctx->Unmap(pPSConstantBuffer, 0);

	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::Update_PSConstantBufferData_D3D11()
{
	m_PSConstantBufferData.FX_param1 = m_FX_param1;
	m_PSConstantBufferData.FX_param2 = m_FX_param2;
	m_PSConstantBufferData.FX_param3 = m_FX_param3;

	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::ReadResource(const WCHAR* resourceType, const WCHAR* resourceName, SIZE_T* size, LPVOID* data)
{
	HRESULT hr = S_FALSE;

	HRSRC rc = FindResource(hInstance, resourceName, resourceType);
	if (!rc) return S_FALSE;

	HGLOBAL rcData = LoadResource(hInstance, rc);
	if (!rcData) return S_FALSE;

	*size = (SIZE_T)SizeofResource(hInstance, rc);
	if (*size == 0) return S_FALSE;

	*data = LockResource(rcData);
	if (*data == nullptr) return S_FALSE;

	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::GetInfoFromShaderResourceView(ID3D11ShaderResourceView* pShaderResourceView, InfoTexture2D* info)
{
	HRESULT hr = S_FALSE;

	D3D11_SHADER_RESOURCE_VIEW_DESC viewDesc;
	ZeroMemory(&viewDesc, sizeof(D3D11_SHADER_RESOURCE_VIEW_DESC));

	pShaderResourceView->GetDesc(&viewDesc);

	DXGI_FORMAT dxFormat1 = viewDesc.Format;
	D3D11_SRV_DIMENSION ViewDimension = viewDesc.ViewDimension;

	ID3D11Resource* pResource = nullptr;
	pShaderResourceView->GetResource(&pResource);
	if (!pResource) return S_FALSE;

	if (ViewDimension == D3D11_SRV_DIMENSION_TEXTURE2D)
	{
		ID3D11Texture2D* pTexture = nullptr;
		hr = pResource->QueryInterface(__uuidof(ID3D11Texture2D), (void**)&pTexture);
		if (hr != S_OK || !pTexture) return S_FALSE;

		D3D11_TEXTURE2D_DESC textureDesc;
		ZeroMemory(&textureDesc, sizeof(D3D11_TEXTURE2D_DESC));

		pTexture->GetDesc(&textureDesc);

		info->Format = textureDesc.Format;
		info->Width = textureDesc.Width;
		info->Height = textureDesc.Height;

		SAFE_RELEASE(pTexture);
	}

	SAFE_RELEASE(pResource);

	return S_OK;
}
//-----------------------------------------------------------------------
HRESULT CPixelShader8::GetInfoFromRenderTargetView(ID3D11RenderTargetView* pRenderTargetView, InfoTexture2D* info)
{
	HRESULT hr = S_FALSE;

	D3D11_RENDER_TARGET_VIEW_DESC viewDesc;
	ZeroMemory(&viewDesc, sizeof(D3D11_RENDER_TARGET_VIEW_DESC));

	pRenderTargetView->GetDesc(&viewDesc);

	DXGI_FORMAT dxFormat1 = viewDesc.Format;
	D3D11_RTV_DIMENSION ViewDimension = viewDesc.ViewDimension;

	ID3D11Resource* pResource = nullptr;
	pRenderTargetView->GetResource(&pResource);
	if (!pResource) return S_FALSE;

	if (ViewDimension == D3D11_RTV_DIMENSION_TEXTURE2D)
	{
		ID3D11Texture2D* pTexture = nullptr;
		hr = pResource->QueryInterface(__uuidof(ID3D11Texture2D), (void**)&pTexture);
		if (hr != S_OK || !pTexture) return S_FALSE;

		D3D11_TEXTURE2D_DESC textureDesc;
		ZeroMemory(&textureDesc, sizeof(D3D11_TEXTURE2D_DESC));

		pTexture->GetDesc(&textureDesc);

		info->Format = textureDesc.Format;
		info->Width = textureDesc.Width;
		info->Height = textureDesc.Height;

		SAFE_RELEASE(pTexture);
	}

	SAFE_RELEASE(pResource);

	return S_OK;
}