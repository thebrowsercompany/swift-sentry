import Foundation
#if canImport(WinSDK)
import WinSDK
#elseif canImport(CommonCrypto)
import CommonCrypto
#endif

extension Data {
  var SHA1: Data {
    #if canImport(WinSDK)
    func handleError(_ status: WinSDK.NTSTATUS) {
      // Failfast to mimic CryptoKit/Crypto semantics
      if status < 0 { fatalError("Failed to create SHA1 digest using BCrypt APIs (NTSTATUS: \(status))") }
    }

    let BCRYPT_SHA1_ALGORITHM = "SHA1"

    var algorithm: WinSDK.BCRYPT_ALG_HANDLE?
    BCRYPT_SHA1_ALGORITHM.withCString(encodedAs: UTF16.self) {
      handleError(WinSDK.BCryptOpenAlgorithmProvider(&algorithm, $0, nil, 0))
    }
    defer { handleError(WinSDK.BCryptCloseAlgorithmProvider(algorithm, 0)) }

    var hash: BCRYPT_HASH_HANDLE?
    handleError(WinSDK.BCryptCreateHash(algorithm, &hash, nil, 0, nil, 0, 0))
    defer { handleError(WinSDK.BCryptDestroyHash(hash)) }

    withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
        let input = UnsafeMutablePointer(mutating: buffer.baseAddress?.bindMemory(to: UInt8.self, capacity: buffer.count))
        handleError(WinSDK.BCryptHashData(hash, input, ULONG(buffer.count), 0))
    }

    var result = Data(count: 20) // Size of SHA1 hash
    result.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
        let output = buffer.baseAddress?.bindMemory(to: UInt8.self, capacity: buffer.count)
        handleError(WinSDK.BCryptFinishHash(hash, output, ULONG(buffer.count), 0))
    }

    return result
    #elseif canImport(CommonCrypto)
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    withUnsafeBytes {
        _ = CC_SHA1($0.baseAddress, CC_LONG(count), &digest)
    }
    return Data(digest)
    #else
    fatalError("No viable crypto implementation to back hashing function!")
    #endif
  }

  var hexString: String { map { String(format: "%02x", $0) }.joined() }
}
