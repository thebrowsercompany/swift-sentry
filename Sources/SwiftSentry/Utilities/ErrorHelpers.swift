#if os(Windows)
import WinSDK

extension HRESULT {
  var stringRepresentation: String {
    return "0x\(String(DWORD(bitPattern: self), radix: 16))"
  }
}
#endif
