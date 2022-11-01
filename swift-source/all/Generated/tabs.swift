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
        try! rustCall { ffi_tabs_413c_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_tabs_413c_rustbuffer_free(self, $0) }
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
        let _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0, from: range) }
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

private struct FfiConverterInt64: FfiConverterPrimitive {
    typealias FfiType = Int64
    typealias SwiftType = Int64

    static func read(from buf: Reader) throws -> Int64 {
        return try lift(buf.readInt())
    }

    static func write(_ value: Int64, into buf: Writer) {
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

public protocol TabsBridgedEngineProtocol {
    func lastSync() throws -> Int64
    func setLastSync(lastSync: Int64) throws
    func syncId() throws -> String?
    func resetSyncId() throws -> String
    func ensureCurrentSyncId(newSyncId: String) throws -> String
    func prepareForSync(clientData: String) throws
    func syncStarted() throws
    func storeIncoming(incomingEnvelopesAsJson: [String]) throws
    func apply() throws -> [String]
    func setUploaded(newTimestamp: Int64, uploadedIds: [TabsGuid]) throws
    func syncFinished() throws
    func reset() throws
    func wipe() throws
}

public class TabsBridgedEngine: TabsBridgedEngineProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    deinit {
        try! rustCall { ffi_tabs_413c_TabsBridgedEngine_object_free(pointer, $0) }
    }

    public func lastSync() throws -> Int64 {
        return try FfiConverterInt64.lift(
            try
                rustCallWithError(FfiConverterTypeTabsApiError.self) {
                    tabs_413c_TabsBridgedEngine_last_sync(self.pointer, $0)
                }
        )
    }

    public func setLastSync(lastSync: Int64) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_set_last_sync(self.pointer,
                                                          FfiConverterInt64.lower(lastSync), $0)
            }
    }

    public func syncId() throws -> String? {
        return try FfiConverterOptionString.lift(
            try
                rustCallWithError(FfiConverterTypeTabsApiError.self) {
                    tabs_413c_TabsBridgedEngine_sync_id(self.pointer, $0)
                }
        )
    }

    public func resetSyncId() throws -> String {
        return try FfiConverterString.lift(
            try
                rustCallWithError(FfiConverterTypeTabsApiError.self) {
                    tabs_413c_TabsBridgedEngine_reset_sync_id(self.pointer, $0)
                }
        )
    }

    public func ensureCurrentSyncId(newSyncId: String) throws -> String {
        return try FfiConverterString.lift(
            try
                rustCallWithError(FfiConverterTypeTabsApiError.self) {
                    tabs_413c_TabsBridgedEngine_ensure_current_sync_id(self.pointer,
                                                                       FfiConverterString.lower(newSyncId), $0)
                }
        )
    }

    public func prepareForSync(clientData: String) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_prepare_for_sync(self.pointer,
                                                             FfiConverterString.lower(clientData), $0)
            }
    }

    public func syncStarted() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_sync_started(self.pointer, $0)
            }
    }

    public func storeIncoming(incomingEnvelopesAsJson: [String]) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_store_incoming(self.pointer,
                                                           FfiConverterSequenceString.lower(incomingEnvelopesAsJson), $0)
            }
    }

    public func apply() throws -> [String] {
        return try FfiConverterSequenceString.lift(
            try
                rustCallWithError(FfiConverterTypeTabsApiError.self) {
                    tabs_413c_TabsBridgedEngine_apply(self.pointer, $0)
                }
        )
    }

    public func setUploaded(newTimestamp: Int64, uploadedIds: [TabsGuid]) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_set_uploaded(self.pointer,
                                                         FfiConverterInt64.lower(newTimestamp),
                                                         FfiConverterSequenceTypeTabsGuid.lower(uploadedIds), $0)
            }
    }

    public func syncFinished() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_sync_finished(self.pointer, $0)
            }
    }

    public func reset() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_reset(self.pointer, $0)
            }
    }

    public func wipe() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsBridgedEngine_wipe(self.pointer, $0)
            }
    }
}

private struct FfiConverterTypeTabsBridgedEngine: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = TabsBridgedEngine

    static func read(from buf: Reader) throws -> TabsBridgedEngine {
        let v: UInt64 = try buf.readInt()
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    static func write(_ value: TabsBridgedEngine, into buf: Writer) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        buf.writeInt(UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    static func lift(_ pointer: UnsafeMutableRawPointer) throws -> TabsBridgedEngine {
        return TabsBridgedEngine(unsafeFromRawPointer: pointer)
    }

    static func lower(_ value: TabsBridgedEngine) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}

public protocol TabsStoreProtocol {
    func getAll() -> [ClientRemoteTabs]
    func setLocalTabs(remoteTabs: [RemoteTabRecord])
    func registerWithSyncManager()
    func reset() throws
    func sync(keyId: String, accessToken: String, syncKey: String, tokenserverUrl: String, localId: String) throws -> String
    func bridgedEngine() -> TabsBridgedEngine
}

public class TabsStore: TabsStoreProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    public convenience init(path: String) {
        self.init(unsafeFromRawPointer: try!

            rustCall {
                tabs_413c_TabsStore_new(
                    FfiConverterString.lower(path), $0
                )
            })
    }

    deinit {
        try! rustCall { ffi_tabs_413c_TabsStore_object_free(pointer, $0) }
    }

    public func getAll() -> [ClientRemoteTabs] {
        return try! FfiConverterSequenceTypeClientRemoteTabs.lift(
            try!
                rustCall {
                    tabs_413c_TabsStore_get_all(self.pointer, $0)
                }
        )
    }

    public func setLocalTabs(remoteTabs: [RemoteTabRecord]) {
        try!
            rustCall {
                tabs_413c_TabsStore_set_local_tabs(self.pointer,
                                                   FfiConverterSequenceTypeRemoteTabRecord.lower(remoteTabs), $0)
            }
    }

    public func registerWithSyncManager() {
        try!
            rustCall {
                tabs_413c_TabsStore_register_with_sync_manager(self.pointer, $0)
            }
    }

    public func reset() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_413c_TabsStore_reset(self.pointer, $0)
            }
    }

    public func sync(keyId: String, accessToken: String, syncKey: String, tokenserverUrl: String, localId: String) throws -> String {
        return try FfiConverterString.lift(
            try
                rustCallWithError(FfiConverterTypeTabsApiError.self) {
                    tabs_413c_TabsStore_sync(self.pointer,
                                             FfiConverterString.lower(keyId),
                                             FfiConverterString.lower(accessToken),
                                             FfiConverterString.lower(syncKey),
                                             FfiConverterString.lower(tokenserverUrl),
                                             FfiConverterString.lower(localId), $0)
                }
        )
    }

    public func bridgedEngine() -> TabsBridgedEngine {
        return try! FfiConverterTypeTabsBridgedEngine.lift(
            try!
                rustCall {
                    tabs_413c_TabsStore_bridged_engine(self.pointer, $0)
                }
        )
    }
}

private struct FfiConverterTypeTabsStore: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = TabsStore

    static func read(from buf: Reader) throws -> TabsStore {
        let v: UInt64 = try buf.readInt()
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    static func write(_ value: TabsStore, into buf: Writer) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        buf.writeInt(UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    static func lift(_ pointer: UnsafeMutableRawPointer) throws -> TabsStore {
        return TabsStore(unsafeFromRawPointer: pointer)
    }

    static func lower(_ value: TabsStore) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}

public struct ClientRemoteTabs {
    public var clientId: String
    public var clientName: String
    public var deviceType: TabsDeviceType
    public var remoteTabs: [RemoteTabRecord]

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(clientId: String, clientName: String, deviceType: TabsDeviceType, remoteTabs: [RemoteTabRecord]) {
        self.clientId = clientId
        self.clientName = clientName
        self.deviceType = deviceType
        self.remoteTabs = remoteTabs
    }
}

extension ClientRemoteTabs: Equatable, Hashable {
    public static func == (lhs: ClientRemoteTabs, rhs: ClientRemoteTabs) -> Bool {
        if lhs.clientId != rhs.clientId {
            return false
        }
        if lhs.clientName != rhs.clientName {
            return false
        }
        if lhs.deviceType != rhs.deviceType {
            return false
        }
        if lhs.remoteTabs != rhs.remoteTabs {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(clientId)
        hasher.combine(clientName)
        hasher.combine(deviceType)
        hasher.combine(remoteTabs)
    }
}

private struct FfiConverterTypeClientRemoteTabs: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> ClientRemoteTabs {
        return try ClientRemoteTabs(
            clientId: FfiConverterString.read(from: buf),
            clientName: FfiConverterString.read(from: buf),
            deviceType: FfiConverterTypeTabsDeviceType.read(from: buf),
            remoteTabs: FfiConverterSequenceTypeRemoteTabRecord.read(from: buf)
        )
    }

    fileprivate static func write(_ value: ClientRemoteTabs, into buf: Writer) {
        FfiConverterString.write(value.clientId, into: buf)
        FfiConverterString.write(value.clientName, into: buf)
        FfiConverterTypeTabsDeviceType.write(value.deviceType, into: buf)
        FfiConverterSequenceTypeRemoteTabRecord.write(value.remoteTabs, into: buf)
    }
}

public struct RemoteTabRecord {
    public var title: String
    public var urlHistory: [String]
    public var icon: String?
    public var lastUsed: Int64

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(title: String, urlHistory: [String], icon: String?, lastUsed: Int64) {
        self.title = title
        self.urlHistory = urlHistory
        self.icon = icon
        self.lastUsed = lastUsed
    }
}

extension RemoteTabRecord: Equatable, Hashable {
    public static func == (lhs: RemoteTabRecord, rhs: RemoteTabRecord) -> Bool {
        if lhs.title != rhs.title {
            return false
        }
        if lhs.urlHistory != rhs.urlHistory {
            return false
        }
        if lhs.icon != rhs.icon {
            return false
        }
        if lhs.lastUsed != rhs.lastUsed {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(urlHistory)
        hasher.combine(icon)
        hasher.combine(lastUsed)
    }
}

private struct FfiConverterTypeRemoteTabRecord: FfiConverterRustBuffer {
    fileprivate static func read(from buf: Reader) throws -> RemoteTabRecord {
        return try RemoteTabRecord(
            title: FfiConverterString.read(from: buf),
            urlHistory: FfiConverterSequenceString.read(from: buf),
            icon: FfiConverterOptionString.read(from: buf),
            lastUsed: FfiConverterInt64.read(from: buf)
        )
    }

    fileprivate static func write(_ value: RemoteTabRecord, into buf: Writer) {
        FfiConverterString.write(value.title, into: buf)
        FfiConverterSequenceString.write(value.urlHistory, into: buf)
        FfiConverterOptionString.write(value.icon, into: buf)
        FfiConverterInt64.write(value.lastUsed, into: buf)
    }
}

// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.
public enum TabsDeviceType {
    case desktop
    case mobile
    case tablet
    case vr
    case tv
    case unknown
}

private struct FfiConverterTypeTabsDeviceType: FfiConverterRustBuffer {
    typealias SwiftType = TabsDeviceType

    static func read(from buf: Reader) throws -> TabsDeviceType {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .desktop

        case 2: return .mobile

        case 3: return .tablet

        case 4: return .vr

        case 5: return .tv

        case 6: return .unknown

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    static func write(_ value: TabsDeviceType, into buf: Writer) {
        switch value {
        case .desktop:
            buf.writeInt(Int32(1))

        case .mobile:
            buf.writeInt(Int32(2))

        case .tablet:
            buf.writeInt(Int32(3))

        case .vr:
            buf.writeInt(Int32(4))

        case .tv:
            buf.writeInt(Int32(5))

        case .unknown:
            buf.writeInt(Int32(6))
        }
    }
}

extension TabsDeviceType: Equatable, Hashable {}

public enum TabsApiError {
    case SyncError(reason: String)
    case SqlError(reason: String)
    case UnexpectedTabsError(reason: String)
}

private struct FfiConverterTypeTabsApiError: FfiConverterRustBuffer {
    typealias SwiftType = TabsApiError

    static func read(from buf: Reader) throws -> TabsApiError {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .SyncError(
                reason: try FfiConverterString.read(from: buf)
            )
        case 2: return .SqlError(
                reason: try FfiConverterString.read(from: buf)
            )
        case 3: return .UnexpectedTabsError(
                reason: try FfiConverterString.read(from: buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    static func write(_ value: TabsApiError, into buf: Writer) {
        switch value {
        case let .SyncError(reason):
            buf.writeInt(Int32(1))
            FfiConverterString.write(reason, into: buf)

        case let .SqlError(reason):
            buf.writeInt(Int32(2))
            FfiConverterString.write(reason, into: buf)

        case let .UnexpectedTabsError(reason):
            buf.writeInt(Int32(3))
            FfiConverterString.write(reason, into: buf)
        }
    }
}

extension TabsApiError: Equatable, Hashable {}

extension TabsApiError: Error {}

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

private struct FfiConverterSequenceString: FfiConverterRustBuffer {
    typealias SwiftType = [String]

    static func write(_ value: [String], into buf: Writer) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            FfiConverterString.write(item, into: buf)
        }
    }

    static func read(from buf: Reader) throws -> [String] {
        let len: Int32 = try buf.readInt()
        var seq = [String]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try FfiConverterString.read(from: buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypeClientRemoteTabs: FfiConverterRustBuffer {
    typealias SwiftType = [ClientRemoteTabs]

    static func write(_ value: [ClientRemoteTabs], into buf: Writer) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            FfiConverterTypeClientRemoteTabs.write(item, into: buf)
        }
    }

    static func read(from buf: Reader) throws -> [ClientRemoteTabs] {
        let len: Int32 = try buf.readInt()
        var seq = [ClientRemoteTabs]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try FfiConverterTypeClientRemoteTabs.read(from: buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypeRemoteTabRecord: FfiConverterRustBuffer {
    typealias SwiftType = [RemoteTabRecord]

    static func write(_ value: [RemoteTabRecord], into buf: Writer) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            FfiConverterTypeRemoteTabRecord.write(item, into: buf)
        }
    }

    static func read(from buf: Reader) throws -> [RemoteTabRecord] {
        let len: Int32 = try buf.readInt()
        var seq = [RemoteTabRecord]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try FfiConverterTypeRemoteTabRecord.read(from: buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypeTabsGuid: FfiConverterRustBuffer {
    typealias SwiftType = [TabsGuid]

    static func write(_ value: [TabsGuid], into buf: Writer) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            FfiConverterTypeTabsGuid.write(item, into: buf)
        }
    }

    static func read(from buf: Reader) throws -> [TabsGuid] {
        let len: Int32 = try buf.readInt()
        var seq = [TabsGuid]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try FfiConverterTypeTabsGuid.read(from: buf))
        }
        return seq
    }
}

/**
 * Typealias from the type name used in the UDL file to the builtin type.  This
 * is needed because the UDL type name is used in function/method signatures.
 */
public typealias TabsGuid = String
private typealias FfiConverterTypeTabsGuid = FfiConverterString

/**
 * Top level initializers and tear down methods.
 *
 * This is generated by uniffi.
 */
public enum TabsLifecycle {
    /**
     * Initialize the FFI and Rust library. This should be only called once per application.
     */
    func initialize() {}
}
