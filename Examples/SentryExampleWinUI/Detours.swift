import Detours
import WinSDK
import Foundation

public func DllMain(hModule: HINSTANCE, reason: DWORD, reserved: LPVOID) -> WindowsBool {
    print("DllMain called with reason \(reason)")
    fflush(stdout)
    return true
}