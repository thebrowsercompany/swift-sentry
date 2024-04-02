#pragma once

#include <windows.h>

// From
// https://docs.microsoft.com/en-us/windows/win32/wer/stowed-exception-information-v2
typedef struct _STOWED_EXCEPTION_INFORMATION_HEADER {
  ULONG size;
  ULONG signature;
} STOWED_EXCEPTION_INFORMATION_HEADER, *PSTOWED_EXCEPTION_INFORMATION_HEADER;

// This is a simplified version of the _STOWED_EXCEPTION_INFORMATION_V2
// structure for better interoperability with Swift. The exceptionForm and
// threadID fields have been merged in the same DWORD as the compiler doesn't
// seem to like bitfields, and the union has been removed as this struct is only
// used with the version of the struct that reports a stack trace (the other
// form reports a text representation of the issue, it's not supported anymore).
typedef struct _STOWED_EXCEPTION_INFORMATION_V2 {
  STOWED_EXCEPTION_INFORMATION_HEADER header;
  HRESULT resultCode;
  DWORD exceptionFormThreadId;
  PVOID exceptionAddress;
  ULONG stackTraceWordSize;
  ULONG stackTraceCount;
  PVOID stackTrace;
  ULONG nestedExceptionType;
  PVOID nestedException;
} STOWED_EXCEPTION_INFORMATION_V2, *PSTOWED_EXCEPTION_INFORMATION_V2;
