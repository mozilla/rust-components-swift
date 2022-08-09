// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(MozillaRustComponents)
    import MozillaRustComponents
#endif

private extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_push_be6b_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_push_be6b_rustbuffer_free(self, $0) }
    }
}

private extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a libray of its own.

private extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// A helper class to read values out of a byte buffer.
private class Reader {
    let data: Data
    var offset: Data.Index

    init(data: Data) {
        self.data = data
        offset = 0
    }

    // Reads an integer at the current offset, in big-endian order, and advances
    // the offset on success. Throws if reading the integer would move the
    // offset past the end of the buffer.
    func readInt<T: FixedWidthInteger>() throws -> T {
        let range = offset ..< offset + MemoryLayout<T>.size
        guard data.count >= range.upperBound else {
            throw UniffiInternalError.bufferOverflow
        }
        if T.self == UInt8.self {
            let value = data[offset]
            offset += 1
            return value as! T
        }
        var value: T = 0
        _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0, from: range) }
        offset = range.upperBound
        return value.bigEndian
    }

    // Reads an arbitrary number of bytes, to be used to read
    // raw bytes, this is useful when lifting strings
    func readBytes(count: Int) throws -> [UInt8] {
        let range = offset ..< (offset + count)
        guard data.count >= range.upperBound else {
            throw UniffiInternalError.bufferOverflow
        }
        var value = [UInt8](repeating: 0, count: count)
        value.withUnsafeMutableBufferPointer { buffer in
            data.copyBytes(to: buffer, from: range)
        }
        offset = range.upperBound
        return value
    }

    // Reads a float at the current offset.
    @inlinable
    func readFloat() throws -> Float {
        return Float(bitPattern: try readInt())
    }

    // Reads a float at the current offset.
    @inlinable
    func readDouble() throws -> Double {
        return Double(bitPattern: try readInt())
    }

    // Indicates if the offset has reached the end of the buffer.
    @inlinable
    func hasRemaining() -> Bool {
        return offset < data.count
    }
}

// A helper class to write values into a byte buffer.
private class Writer {
    var bytes: [UInt8]
    var offset: Array<UInt8>.Index

    init() {
        bytes = []
        offset = 0
    }

    func writeBytes<S>(_ byteArr: S) where S: Sequence, S.Element == UInt8 {
        bytes.append(contentsOf: byteArr)
    }

    // Writes an integer in big-endian order.
    //
    // Warning: make sure what you are trying to write
    // is in the correct type!
    func writeInt<T: FixedWidthInteger>(_ value: T) {
        var value = value.bigEndian
        withUnsafeBytes(of: &value) { bytes.append(contentsOf: $0) }
    }

    @inlinable
    func writeFloat(_ value: Float) {
        writeInt(value.bitPattern)
    }

    @inlinable
    func writeDouble(_ value: Double) {
        writeInt(value.bitPattern)
    }
}

// Protocol for types that transfer other types across the FFI. This is
// analogous go the Rust trait of the same name.
private protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: Reader) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: Writer)
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
private protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType {}

extension FfiConverterPrimitive {
    static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
private protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    static func lift(_ buf: RustBuffer) throws -> SwiftType {
        let reader = Reader(data: Data(rustBuffer: buf))
        let value = try read(from: reader)
        if reader.hasRemaining() {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    static func lower(_ value: SwiftType) -> RustBuffer {
        let writer = Writer()
        write(value, into: writer)
        return RustBuffer(bytes: writer.bytes)
    }
}

// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
private enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

private let CALL_SUCCESS: Int8 = 0
private let CALL_ERROR: Int8 = 1
private let CALL_PANIC: Int8 = 2

private extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: {
        $0.deallocate()
        return UniffiInternalError.unexpectedRustCallError
    })
}

private func rustCallWithError<T, F: FfiConverter>
(_ errorFfiConverter: F.Type, _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T
    where F.SwiftType: Error, F.FfiType == RustBuffer
{
    try makeRustCall(callback, errorHandler: { try errorFfiConverter.lift($0) })
}

private func makeRustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T, errorHandler: (RustBuffer) throws -> Error) throws -> T {
    var callStatus = RustCallStatus()
    let returnedVal = callback(&callStatus)
    switch callStatus.code {
    case CALL_SUCCESS:
        return returnedVal

    case CALL_ERROR:
        throw try errorHandler(callStatus.errorBuf)

    case CALL_PANIC:
        // When the rust code sees a panic, it tries to construct a RustBuffer
        // with the message.  But if that code panics, then it just sends back
        // an empty buffer.
        if callStatus.errorBuf.len > 0 {
            throw UniffiInternalError.rustPanic(try FfiConverterString.lift(callStatus.errorBuf))
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.rustPanic("Rust panic")
        }

    default:
        throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

// Public interface members begin here.

private struct FfiConverterInt8: FfiConverterPrimitive {
    typealias FfiType = Int8
    typealias SwiftType = Int8

    static func read(from buf: Reader) throws -> Int8 {
        return try lift(buf.readInt())
    }

    static func write(_ value: Int8, into buf: Writer) {
        buf.writeInt(lower(value))
    }
}

private struct FfiConverterBool: FfiConverter {
    typealias FfiType = Int8
    typealias SwiftType = Bool

    static func lift(_ value: Int8) throws -> Bool {
        return value != 0
    }

    static func lower(_ value: Bool) -> Int8 {
        return value ? 1 : 0
    }

    static func read(from buf: Reader) throws -> Bool {
        return try lift(buf.readInt())
    }

    static func write(_ value: Bool, into buf: Writer) {
        buf.writeInt(lower(value))
    }
}

private struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    static func read(from buf: Reader) throws -> String {
        let len: Int32 = try buf.readInt()
        return String(bytes: try buf.readBytes(count: Int(len)), encoding: String.Encoding.utf8)!
    }

    static func write(_ value: String, into buf: Writer) {
        let len = Int32(value.utf8.count)
        buf.writeInt(len)
        buf.writeBytes(value.utf8)
    }
}

public protocol PushManagerProtocol {
    func subscribe(channelId: String, scope: String, appServerSey: String?) throws -> SubscriptionResponse
    func unsubscribe(channelId: String) throws -> Bool
    func unsubscribeAll() throws
    func update(registrationToken: String) throws -> Bool
    func verifyConnection() throws -> [PushSubscriptionChanged]
    func decrypt(channelId: String, body: String, encoding: String, salt: String, dh: String) throws -> [Int8]
    func dispatchInfoForChid(channelId: String) throws -> DispatchInfo?
}

public class PushManager: PushManagerProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    public convenience init(senderId: String, serverHost: String = "updates.push.services.mozilla.com", httpProtocol: String = "https", bridgeType: BridgeType, registrationId: String = "", databasePath: String = "push.sqlite") throws {
        self.init(unsafeFromRawPointer: try

            rustCallWithError(FfiConverterTypePushError.self) {
                push_be6b_PushManager_new(
                    FfiConverterString.lower(senderId),
                    FfiConverterString.lower(serverHost),
                    FfiConverterString.lower(httpProtocol),
                    FfiConverterTypeBridgeType.lower(bridgeType),
                    FfiConverterString.lower(registrationId),
                    FfiConverterString.lower(databasePath), $0
                )
            })
    }

    deinit {
        try! rustCall { ffi_push_be6b_PushManager_object_free(pointer, $0) }
    }

    public func subscribe(channelId: String = "", scope: String = "", appServerSey: String? = nil) throws -> SubscriptionResponse {
        return try FfiConverterTypeSubscriptionResponse.lift(
            try
                rustCallWithError(FfiConverterTypePushError.self) {
                    push_be6b_PushManager_subscribe(self.pointer,
                                                    FfiConverterString.lower(channelId),
                                                    FfiConverterString.lower(scope),
                                                    FfiConverterOptionString.lower(appServerSey), $0)
                }
        )
    }

    public func unsubscribe(channelId: String) throws -> Bool {
        return try FfiConverterBool.lift(
            try
                rustCallWithError(FfiConverterTypePushError.self) {
                    push_be6b_PushManager_unsubscribe(self.pointer,
                                                      FfiConverterString.lower(channelId), $0)
                }
        )
    }

    public func unsubscribeAll() throws {
        try
            rustCallWithError(FfiConverterTypePushError.self) {
                push_be6b_PushManager_unsubscribe_all(self.pointer, $0)
            }
    }

    public func update(registrationToken: String) throws -> Bool {
        return try FfiConverterBool.lift(
            try
                rustCallWithError(FfiConverterTypePushError.self) {
                    push_be6b_PushManager_update(self.pointer,
                                                 FfiConverterString.lower(registrationToken), $0)
                }
        )
    }

    public func verifyConnection() throws -> [PushSubscriptionChanged] {
        return try FfiConverterSequenceTypePushSubscriptionChanged.lift(
            try
                rustCallWithError(FfiConverterTypePushError.self) {
                    push_be6b_PushManager_verify_connection(self.pointer, $0)
                }
        )
    }

    public func decrypt(channelId: String, body: String, encoding: String = "aes128gcm", salt: String = "", dh: String = "") throws -> [Int8] {
        return try FfiConverterSequenceInt8.lift(
            try
                rustCallWithError(FfiConverterTypePushError.self) {
                    push_be6b_PushManager_decrypt(self.pointer,
                                                  FfiConverterString.lower(channelId),
                                                  FfiConverterString.lower(body),
                                                  FfiConverterString.lower(encoding),
                                                  FfiConverterString.lower(salt),
                                                  FfiConverterString.lower(dh), $0)
                }
        )
    }

    public func dispatchInfoForChid(channelId: String) throws -> DispatchInfo? {
        return try FfiConverterOptionTypeDispatchInfo.lift(
            try
                rustCallWithError(FfiConverterTypePushError.self) {
                    push_be6b_PushManager_dispatch_info_for_chid(self.pointer,
                                                                 FfiConverterString.lower(channelId), $0)
                }
        )
    }
}

private struct FfiConverterTypePushManager: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = PushManager

    static func read(from buf: Reader) throws -> PushManager {
        let v: UInt64 = try buf.readInt()
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    static func write(_ value: PushManager, into buf: Writer) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        buf.writeInt(UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    static func lift(_ pointer: UnsafeMutableRawPointer) throws -> PushManager {
        return PushManager(unsafeFromRawPointer: pointer)
    }

    static func lower(_ value: PushManager) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}

public struct DispatchInfo {
    public var scope: String
    public var endpoint: String
    public var appServerKey: String?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(scope: String, endpoint: String, appServerKey: String?) {
        self.scope = scope
        self.endpoint = endpoint
        self.appServerKey = appServerKey
    }
}

extension DispatchInfo: Equatable, Hashable {
    public static func == (lhs: DispatchInfo, rhs: DispatchInfo) -> Bool {
        if lhs.scope != rhs.scope {
            return false
        }
        if lhs.endpoint != rhs.endpoint {
            return false
        }
        if lhs.appServerKey != rhs.appServerKey {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(scope)
        hasher.combine(endpoint)
        hasher.combine(appServerKey)
    }
}

private struct FfiConverterTypeDispatchInfo: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> DispatchInfo {
        return try DispatchInfo(
            scope: FfiConverterString.read(from: buf),
            endpoint: FfiConverterString.read(from: buf),
            appServerKey: FfiConverterOptionString.read(from: buf)
        )
    }

    fileprivate static func write(_ value: DispatchInfo, into buf: Writer) {
        FfiConverterString.write(value.scope, into: buf)
        FfiConverterString.write(value.endpoint, into: buf)
        FfiConverterOptionString.write(value.appServerKey, into: buf)
    }
}

public struct KeyInfo {
    public var auth: String
    public var p256dh: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(auth: String, p256dh: String) {
        self.auth = auth
        self.p256dh = p256dh
    }
}

extension KeyInfo: Equatable, Hashable {
    public static func == (lhs: KeyInfo, rhs: KeyInfo) -> Bool {
        if lhs.auth != rhs.auth {
            return false
        }
        if lhs.p256dh != rhs.p256dh {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(auth)
        hasher.combine(p256dh)
    }
}

private struct FfiConverterTypeKeyInfo: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> KeyInfo {
        return try KeyInfo(
            auth: FfiConverterString.read(from: buf),
            p256dh: FfiConverterString.read(from: buf)
        )
    }

    fileprivate static func write(_ value: KeyInfo, into buf: Writer) {
        FfiConverterString.write(value.auth, into: buf)
        FfiConverterString.write(value.p256dh, into: buf)
    }
}

public struct PushSubscriptionChanged {
    public var channelId: String
    public var scope: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(channelId: String, scope: String) {
        self.channelId = channelId
        self.scope = scope
    }
}

extension PushSubscriptionChanged: Equatable, Hashable {
    public static func == (lhs: PushSubscriptionChanged, rhs: PushSubscriptionChanged) -> Bool {
        if lhs.channelId != rhs.channelId {
            return false
        }
        if lhs.scope != rhs.scope {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(channelId)
        hasher.combine(scope)
    }
}

private struct FfiConverterTypePushSubscriptionChanged: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> PushSubscriptionChanged {
        return try PushSubscriptionChanged(
            channelId: FfiConverterString.read(from: buf),
            scope: FfiConverterString.read(from: buf)
        )
    }

    fileprivate static func write(_ value: PushSubscriptionChanged, into buf: Writer) {
        FfiConverterString.write(value.channelId, into: buf)
        FfiConverterString.write(value.scope, into: buf)
    }
}

public struct SubscriptionInfo {
    public var endpoint: String
    public var keys: KeyInfo

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(endpoint: String, keys: KeyInfo) {
        self.endpoint = endpoint
        self.keys = keys
    }
}

extension SubscriptionInfo: Equatable, Hashable {
    public static func == (lhs: SubscriptionInfo, rhs: SubscriptionInfo) -> Bool {
        if lhs.endpoint != rhs.endpoint {
            return false
        }
        if lhs.keys != rhs.keys {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(endpoint)
        hasher.combine(keys)
    }
}

private struct FfiConverterTypeSubscriptionInfo: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> SubscriptionInfo {
        return try SubscriptionInfo(
            endpoint: FfiConverterString.read(from: buf),
            keys: FfiConverterTypeKeyInfo.read(from: buf)
        )
    }

    fileprivate static func write(_ value: SubscriptionInfo, into buf: Writer) {
        FfiConverterString.write(value.endpoint, into: buf)
        FfiConverterTypeKeyInfo.write(value.keys, into: buf)
    }
}

public struct SubscriptionResponse {
    public var channelId: String
    public var subscriptionInfo: SubscriptionInfo

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(channelId: String, subscriptionInfo: SubscriptionInfo) {
        self.channelId = channelId
        self.subscriptionInfo = subscriptionInfo
    }
}

extension SubscriptionResponse: Equatable, Hashable {
    public static func == (lhs: SubscriptionResponse, rhs: SubscriptionResponse) -> Bool {
        if lhs.channelId != rhs.channelId {
            return false
        }
        if lhs.subscriptionInfo != rhs.subscriptionInfo {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(channelId)
        hasher.combine(subscriptionInfo)
    }
}

private struct FfiConverterTypeSubscriptionResponse: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> SubscriptionResponse {
        return try SubscriptionResponse(
            channelId: FfiConverterString.read(from: buf),
            subscriptionInfo: FfiConverterTypeSubscriptionInfo.read(from: buf)
        )
    }

    fileprivate static func write(_ value: SubscriptionResponse, into buf: Writer) {
        FfiConverterString.write(value.channelId, into: buf)
        FfiConverterTypeSubscriptionInfo.write(value.subscriptionInfo, into: buf)
    }
}

// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.
public enum BridgeType {
    case fcm
    case adm
    case apns
    case test
}

private struct FfiConverterTypeBridgeType: FfiConverterRustBuffer {
    typealias SwiftType = BridgeType

    static func read(from buf: Reader) throws -> BridgeType {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .fcm

        case 2: return .adm

        case 3: return .apns

        case 4: return .test

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    static func write(_ value: BridgeType, into buf: Writer) {
        switch value {
        case .fcm:
            buf.writeInt(Int32(1))

        case .adm:
            buf.writeInt(Int32(2))

        case .apns:
            buf.writeInt(Int32(3))

        case .test:
            buf.writeInt(Int32(4))
        }
    }
}

extension BridgeType: Equatable, Hashable {}

public enum PushError {
    // Simple error enums only carry a message
    case GeneralError(message: String)

    // Simple error enums only carry a message
    case CryptoError(message: String)

    // Simple error enums only carry a message
    case CommunicationError(message: String)

    // Simple error enums only carry a message
    case CommunicationServerError(message: String)

    // Simple error enums only carry a message
    case AlreadyRegisteredError(message: String)

    // Simple error enums only carry a message
    case StorageError(message: String)

    // Simple error enums only carry a message
    case RecordNotFoundError(message: String)

    // Simple error enums only carry a message
    case StorageSqlError(message: String)

    // Simple error enums only carry a message
    case MissingRegistrationTokenError(message: String)

    // Simple error enums only carry a message
    case TranscodingError(message: String)

    // Simple error enums only carry a message
    case UrlParseError(message: String)

    // Simple error enums only carry a message
    case JsonDeserializeError(message: String)

    // Simple error enums only carry a message
    case UaidNotRecognizedError(message: String)

    // Simple error enums only carry a message
    case RequestError(message: String)

    // Simple error enums only carry a message
    case OpenDatabaseError(message: String)
}

private struct FfiConverterTypePushError: FfiConverterRustBuffer {
    typealias SwiftType = PushError

    static func read(from buf: Reader) throws -> PushError {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .GeneralError(
                message: try FfiConverterString.read(from: buf)
            )

        case 2: return .CryptoError(
                message: try FfiConverterString.read(from: buf)
            )

        case 3: return .CommunicationError(
                message: try FfiConverterString.read(from: buf)
            )

        case 4: return .CommunicationServerError(
                message: try FfiConverterString.read(from: buf)
            )

        case 5: return .AlreadyRegisteredError(
                message: try FfiConverterString.read(from: buf)
            )

        case 6: return .StorageError(
                message: try FfiConverterString.read(from: buf)
            )

        case 7: return .RecordNotFoundError(
                message: try FfiConverterString.read(from: buf)
            )

        case 8: return .StorageSqlError(
                message: try FfiConverterString.read(from: buf)
            )

        case 9: return .MissingRegistrationTokenError(
                message: try FfiConverterString.read(from: buf)
            )

        case 10: return .TranscodingError(
                message: try FfiConverterString.read(from: buf)
            )

        case 11: return .UrlParseError(
                message: try FfiConverterString.read(from: buf)
            )

        case 12: return .JsonDeserializeError(
                message: try FfiConverterString.read(from: buf)
            )

        case 13: return .UaidNotRecognizedError(
                message: try FfiConverterString.read(from: buf)
            )

        case 14: return .RequestError(
                message: try FfiConverterString.read(from: buf)
            )

        case 15: return .OpenDatabaseError(
                message: try FfiConverterString.read(from: buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    static func write(_ value: PushError, into buf: Writer) {
        switch value {
        case let .GeneralError(message):
            buf.writeInt(Int32(1))
            FfiConverterString.write(message, into: buf)
        case let .CryptoError(message):
            buf.writeInt(Int32(2))
            FfiConverterString.write(message, into: buf)
        case let .CommunicationError(message):
            buf.writeInt(Int32(3))
            FfiConverterString.write(message, into: buf)
        case let .CommunicationServerError(message):
            buf.writeInt(Int32(4))
            FfiConverterString.write(message, into: buf)
        case let .AlreadyRegisteredError(message):
            buf.writeInt(Int32(5))
            FfiConverterString.write(message, into: buf)
        case let .StorageError(message):
            buf.writeInt(Int32(6))
            FfiConverterString.write(message, into: buf)
        case let .RecordNotFoundError(message):
            buf.writeInt(Int32(7))
            FfiConverterString.write(message, into: buf)
        case let .StorageSqlError(message):
            buf.writeInt(Int32(8))
            FfiConverterString.write(message, into: buf)
        case let .MissingRegistrationTokenError(message):
            buf.writeInt(Int32(9))
            FfiConverterString.write(message, into: buf)
        case let .TranscodingError(message):
            buf.writeInt(Int32(10))
            FfiConverterString.write(message, into: buf)
        case let .UrlParseError(message):
            buf.writeInt(Int32(11))
            FfiConverterString.write(message, into: buf)
        case let .JsonDeserializeError(message):
            buf.writeInt(Int32(12))
            FfiConverterString.write(message, into: buf)
        case let .UaidNotRecognizedError(message):
            buf.writeInt(Int32(13))
            FfiConverterString.write(message, into: buf)
        case let .RequestError(message):
            buf.writeInt(Int32(14))
            FfiConverterString.write(message, into: buf)
        case let .OpenDatabaseError(message):
            buf.writeInt(Int32(15))
            FfiConverterString.write(message, into: buf)
        }
    }
}

extension PushError: Equatable, Hashable {}

extension PushError: Error {}

private struct FfiConverterOptionString: FfiConverterRustBuffer {
    typealias SwiftType = String?

    static func write(_ value: SwiftType, into buf: Writer) {
        guard let value = value else {
            buf.writeInt(Int8(0))
            return
        }
        buf.writeInt(Int8(1))
        FfiConverterString.write(value, into: buf)
    }

    static func read(from buf: Reader) throws -> SwiftType {
        switch try buf.readInt() as Int8 {
        case 0: return nil
        case 1: return try FfiConverterString.read(from: buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

private struct FfiConverterOptionTypeDispatchInfo: FfiConverterRustBuffer {
    typealias SwiftType = DispatchInfo?

    static func write(_ value: SwiftType, into buf: Writer) {
        guard let value = value else {
            buf.writeInt(Int8(0))
            return
        }
        buf.writeInt(Int8(1))
        FfiConverterTypeDispatchInfo.write(value, into: buf)
    }

    static func read(from buf: Reader) throws -> SwiftType {
        switch try buf.readInt() as Int8 {
        case 0: return nil
        case 1: return try FfiConverterTypeDispatchInfo.read(from: buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

private struct FfiConverterSequenceInt8: FfiConverterRustBuffer {
    typealias SwiftType = [Int8]

    static func write(_ value: [Int8], into buf: Writer) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            FfiConverterInt8.write(item, into: buf)
        }
    }

    static func read(from buf: Reader) throws -> [Int8] {
        let len: Int32 = try buf.readInt()
        var seq = [Int8]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try FfiConverterInt8.read(from: buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypePushSubscriptionChanged: FfiConverterRustBuffer {
    typealias SwiftType = [PushSubscriptionChanged]

    static func write(_ value: [PushSubscriptionChanged], into buf: Writer) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            FfiConverterTypePushSubscriptionChanged.write(item, into: buf)
        }
    }

    static func read(from buf: Reader) throws -> [PushSubscriptionChanged] {
        let len: Int32 = try buf.readInt()
        var seq = [PushSubscriptionChanged]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try FfiConverterTypePushSubscriptionChanged.read(from: buf))
        }
        return seq
    }
}

/**
 * Top level initializers and tear down methods.
 *
 * This is generated by uniffi.
 */
public enum PushLifecycle {
    /**
     * Initialize the FFI and Rust library. This should be only called once per application.
     */
    func initialize() {}
}
