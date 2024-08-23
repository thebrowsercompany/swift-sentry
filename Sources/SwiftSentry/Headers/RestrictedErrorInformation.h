#pragma once

#include <windows.h>
#include <minwindef.h>
#include <combaseapi.h>

// Since C++ interop doesn't support virtual methods, we define the C interface
// ourselves to ensure consistency
typedef interface IRestrictedErrorInfo IRestrictedErrorInfo;
EXTERN_C const IID IID_IRestrictedErrorInfo;
typedef struct IRestrictedErrorInfoVtbl
{
    BEGIN_INTERFACE

    DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
    HRESULT ( STDMETHODCALLTYPE *QueryInterface )(
        __RPC__in IRestrictedErrorInfo * This,
        /* [in] */ __RPC__in REFIID riid,
        /* [annotation][iid_is][out] */
        _COM_Outptr_  void **ppvObject);

    DECLSPEC_XFGVIRT(IUnknown, AddRef)
    ULONG ( STDMETHODCALLTYPE *AddRef )(
        __RPC__in IRestrictedErrorInfo * This);

    DECLSPEC_XFGVIRT(IUnknown, Release)
    ULONG ( STDMETHODCALLTYPE *Release )(
        __RPC__in IRestrictedErrorInfo * This);

    DECLSPEC_XFGVIRT(IRestrictedErrorInfo, GetErrorDetails)
    HRESULT ( STDMETHODCALLTYPE *GetErrorDetails )(
        __RPC__in IRestrictedErrorInfo * This,
        /* [out] */ __RPC__deref_out_opt BSTR *description,
        /* [out] */ __RPC__out HRESULT *error,
        /* [out] */ __RPC__deref_out_opt BSTR *restrictedDescription,
        /* [out] */ __RPC__deref_out_opt BSTR *capabilitySid);

    DECLSPEC_XFGVIRT(IRestrictedErrorInfo, GetReference)
    HRESULT ( STDMETHODCALLTYPE *GetReference )(
        __RPC__in IRestrictedErrorInfo * This,
        /* [out] */ __RPC__deref_out_opt BSTR *reference);

    END_INTERFACE
} IRestrictedErrorInfoVtbl;

interface IRestrictedErrorInfo
{
    CONST_VTBL struct IRestrictedErrorInfoVtbl *lpVtbl;
};

STDAPI GetRestrictedErrorInfo(_Nullable IRestrictedErrorInfo **);