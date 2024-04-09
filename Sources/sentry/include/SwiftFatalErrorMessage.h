// SPDX-License-Identifier: BSD-3-Clause

#ifndef sentry_native_include_Sentry_SwiftFatalErrorMessage_hh
#define sentry_native_include_Sentry_SwiftFatalErrorMessage_hh

#include <sentry.h>

#ifdef _WIN32
#include <atomic>

inline void *getFatalErrorMessageHandle() {
  HMODULE hSwiftCore = GetModuleHandleA("swiftCore.dll");
  if (!hSwiftCore) { return nullptr; }
  auto pGetBuf = reinterpret_cast<std::atomic<const char *> *(*)()>(
      GetProcAddress(hSwiftCore, "swift_getFatalErrorMessageBuffer"));
  CloseHandle(hSwiftCore);
  // Note swift_getFatalErrorMessageBuffer isn't exported in older
  // versions of the Swift toolchain. So it may not exist.
  if (!pGetBuf) { return nullptr; }
  return reinterpret_cast<void*>(pGetBuf());
}

inline const char* loadFatalErrorMessageBuffer(void* handle) {
  auto pBuf = reinterpret_cast<std::atomic<const char *> *>(handle);
  if (!pBuf) { return nullptr; }
  return pBuf->load();
}

#endif // _WIN32

#endif
