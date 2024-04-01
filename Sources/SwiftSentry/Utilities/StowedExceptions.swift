#if os(Windows)
import WinSDK

// From https://learn.microsoft.com/en-us/windows/win32/wer/stowed-exception-information-v2
struct STOWED_EXCEPTION_INFORMATION_V2 {
  // STOWED_EXCEPTION_INFORMATION_HEADER
  var Size: UInt32
  var Signature: UInt32

  // Body
  var ResultCode: HRESULT
  // This combines ExceptionForm and ThreadId into a single UInt32. The C definition for this is:
  // struct {
  //   DWORD ExceptionForm  :2;
  //   DWORD ThreadId       :30;
  // };
  var ExceptionFormThreadId: UInt32
  var ExceptionAddress: UnsafeRawPointer?
  var StackTraceWordSize: UInt32
  var stackTraceCount: UInt32
  var stackTrace: UnsafeRawPointer?
  var NestedExceptionType: UInt32
  var NestedException: UnsafeRawPointer?

  // Helper to access bit fields
  var ExceptionForm: UInt32 {
    get { ExceptionFormThreadId & 0x3 }
  }
}
#endif
