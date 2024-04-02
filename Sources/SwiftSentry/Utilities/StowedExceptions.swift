#if os(Windows)
import stowedExceptions
import WinSDK

extension STOWED_EXCEPTION_INFORMATION_V2 {
  // Helper to access bit fields
  var exceptionForm: UInt32 {
    get { exceptionFormThreadId & 0x3 }
  }
}
#endif
