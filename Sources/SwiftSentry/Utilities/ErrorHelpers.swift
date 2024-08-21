#if os(Windows)
import RoErrorAPI
import WinSDK

struct RestrictedErrorInfo {
  let hr: HRESULT
  let description: String
}

func getRestrictedErrorInfo() -> RestrictedErrorInfo? {
  var errorInfo: UnsafeMutablePointer<IRestrictedErrorInfo>?
  guard GetRestrictedErrorInfo(&errorInfo) == S_OK, let errorInfo else { return nil }
  defer {
    _ = errorInfo.pointee.lpVtbl.pointee.Release(errorInfo)
  }

  var errorDescription: BSTR?
  var restrictedDescription: BSTR?
  var capabilitySid: BSTR?
  defer {
    SysFreeString(errorDescription)
    SysFreeString(restrictedDescription)
    SysFreeString(capabilitySid)
  }
  var resultLocal: HRESULT = S_OK
  _ = errorInfo.pointee.lpVtbl.pointee.GetErrorDetails(
    errorInfo,
    &errorDescription,
    &resultLocal,
    &restrictedDescription,
    &capabilitySid)

  // Favor restrictedDescription as this is a more user friendly message, which
  // is intended to be displayed to the caller to help them understand why the
  // api call failed. If it's not set, then fallback to the generic error message
  // for the result
  if SysStringLen(restrictedDescription) > 0 {
    return .init(hr: resultLocal, description: String(decodingCString: restrictedDescription!, as: UTF16.self))
  } else if SysStringLen(errorDescription) > 0 {
    return .init(hr: resultLocal, description: String(decodingCString: errorDescription!, as: UTF16.self))
  } else {
    return .init(hr: resultLocal, description: hrToString(resultLocal))
  }
}

@_transparent
private func MAKELANGID(_ p: WORD, _ s: WORD) -> DWORD {
  return DWORD((s << 10) | p)
}

private func hrToString(_ hr: HRESULT) -> String {
  let dwFlags: DWORD = DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER)
                       | DWORD(FORMAT_MESSAGE_FROM_SYSTEM)
                       | DWORD(FORMAT_MESSAGE_IGNORE_INSERTS)

    var buffer: UnsafeMutablePointer<WCHAR>? = nil
    let dwResult: DWORD = withUnsafeMutablePointer(to: &buffer) {
      $0.withMemoryRebound(to: WCHAR.self, capacity: 2) {
        FormatMessageW(dwFlags, nil, DWORD(bitPattern: hr),
                       MAKELANGID(WORD(LANG_NEUTRAL), WORD(SUBLANG_DEFAULT)),
                       $0, 0, nil)
      }
    }
    guard dwResult > 0, let message = buffer else {
      return "HRESULT(\(hr.stringRepresentation))"
    }
    defer { LocalFree(buffer) }
    return "\(hr.stringRepresentation)) - \(String(decodingCString: message, as: UTF16.self))"
}

extension HRESULT {
  var stringRepresentation: String {
    return "0x\(String(DWORD(bitPattern: self), radix: 16))"
  }
}
#endif
