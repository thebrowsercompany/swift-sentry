// SPDX-License-Identifier: BSD-3-Clause

#ifndef sentry_native_include_Sentry_SwiftFatalErrorMessage_hh
#define sentry_native_include_Sentry_SwiftFatalErrorMessage_hh

#include <sentry.h>

#ifdef _WIN32
// swiftc is having trouble with <atomic> in VS 17.10.0 for reasons unclear
// #include <atomic>
// This gunk is all just for the atomic_load in loadFatalErrorMessageBuffer()
// It should be removed ASAP and replaced with:
//   std::atomic<const char*>(pBuf)->load()

////// REMOVE ME START
// This is all copied from an older MSVC STL. Should be removed ASAP!
#define _Compiler_barrier() _ReadWriteBarrier()
#if defined(_M_ARM) || defined(_M_ARM64) || defined(_M_ARM64EC) ||             \
    defined(_M_HYBRID_X86_ARM64)
#define _Memory_barrier() __dmb(0xB) // inner shared data memory barrier
#define _Compiler_or_memory_barrier() _Memory_barrier()
#elif defined(_M_IX86) || defined(_M_X64)
// x86/x64 hardware only emits memory barriers inside _Interlocked intrinsics
#define _Compiler_or_memory_barrier() _Compiler_barrier()
#else // ^^^ x86/x64 / unsupported hardware vvv
#error Unsupported hardware
#endif // hardware

_NODISCARD const char *
atomic_load(const char **p) { // load with sequential consistency
  const auto _Mem = reinterpret_cast<volatile long long*>(&p);
#ifdef _M_ARM
  long long _As_bytes = __ldrexd(_Mem);
#else
  long long _As_bytes = __iso_volatile_load64(_Mem);
#endif
  _Compiler_or_memory_barrier();
  return reinterpret_cast<const char *>(_As_bytes);
}
////// REMOVE ME END

inline void *getFatalErrorMessageHandle() {
  // Docs: "The GetModuleHandle function returns a handle to a mapped module without incrementing its reference count"
  // So we don't need to close it.
  HMODULE hSwiftCore = GetModuleHandleA("swiftCore.dll");
  if (!hSwiftCore) { return nullptr; }
  auto pGetBuf = GetProcAddress(hSwiftCore, "swift_getFatalErrorMessageBuffer");
  // Note swift_getFatalErrorMessageBuffer isn't exported in older
  // versions of the Swift toolchain. So it may not exist.
  if (!pGetBuf) { return nullptr; }
  return reinterpret_cast<void*>(pGetBuf());
}

inline const char* loadFatalErrorMessageBuffer(void* handle) {
  auto pBuf = reinterpret_cast<const char **>(handle);
  if (!pBuf) { return nullptr; }
  return atomic_load(pBuf);
}

#endif // _WIN32

#endif
