import Detours
import WinSDK
import Foundation

@_cdecl("DllMain")
public func DllMain(hModule: HINSTANCE, reason: DWORD, reserved: LPVOID) -> WindowsBool {
    print("DllMain called with reason \(reason)")
    fflush(stdout)
    return true
}

var TrueRaiseFailFastException = WinSDK.RaiseFailFastException
var TrueRaiseFailFastExceptionPtr: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(&TrueRaiseFailFastException)
var DetourPtr: UnsafeMutableRawPointer = UnsafeMutableRawPointer(&Detour)

func DetouredRaiseFailFastException(
    _ exceptionRecord: WinSDK.PEXCEPTION_RECORD,
    _ contextRecord: WinSDK.PCONTEXT,
    _ flags: WinSDK.DWORD) {
    print("Detouring RaiseFailFastException called")
    fflush(stdout)
    //return TrueRaiseFailFastException(exceptionRecord, contextRecord, flags)
}
var Detour: @convention(c) (WinSDK.PEXCEPTION_RECORD, WinSDK.PCONTEXT, WinSDK.DWORD) -> Void = DetouredRaiseFailFastException

func checkFailure(_ closure: @autoclosure () -> LONG) {
    print("calling api...")
    let result = closure()
    if result != 0 {
        print("Failed with error \(result)")
        fflush(stdout)
    }
}

func checkFailure(_ closure: @autoclosure () -> Bool) {
    print("calling api...")
    if !closure() {
        print("Failed")
        fflush(stdout)
    }
}

public func startDetours() {
    print("detouring APIs")
    fflush(stdout)

    checkFailure(DetourRestoreAfterWith())
    checkFailure(DetourTransactionBegin())
    checkFailure(DetourUpdateThread(GetCurrentThread()))

    withUnsafeMutablePointer(to: &TrueRaiseFailFastException) {
        $0.withMemoryRebound(to: PVOID?.self, capacity: 1) { TrueRaiseFailFastExceptionPtr2 in
            //withUnsafePointer(to: &DetouredRaiseFailFastException) {
              //  $0.withMemoryRebound(to: PVOID.self, capacity: 1) { DetourPtr in
                    checkFailure(DetourAttach(TrueRaiseFailFastExceptionPtr2, unsafeBitCast(Detour, to: PVOID.self)))
                //}
           // }
        }
    }

    //checkFailure(DetourAttach(&TrueRaiseFailFastExceptionPtr, DetourPtr))

    checkFailure(DetourTransactionCommit())
}

public func stopDetours() {
    print("restoring APIs")
    fflush(stdout)

    DetourTransactionBegin()
    DetourUpdateThread(GetCurrentThread())

    DetourDetach(&TrueRaiseFailFastExceptionPtr, DetourPtr)

    DetourTransactionCommit()
}