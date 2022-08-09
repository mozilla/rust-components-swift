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
        try! rustCall { ffi_errorsupport_b986_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_errorsupport_b986_rustbuffer_free(self, $0) }
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

private struct FfiConverterUInt32: FfiConverterPrimitive {
    typealias FfiType = UInt32
    typealias SwiftType = UInt32

    static func read(from buf: Reader) throws -> UInt32 {
        return try lift(buf.readInt())
    }

    static func write(_ value: SwiftType, into buf: Writer) {
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

private extension NSLock {
    func withLock<T>(f: () throws -> T) rethrows -> T {
        lock()
        defer { self.unlock() }
        return try f()
    }
}

private typealias Handle = UInt64
private class ConcurrentHandleMap<T> {
    private var leftMap: [Handle: T] = [:]
    private var counter: [Handle: UInt64] = [:]
    private var rightMap: [ObjectIdentifier: Handle] = [:]

    private let lock = NSLock()
    private var currentHandle: Handle = 0
    private let stride: Handle = 1

    func insert(obj: T) -> Handle {
        lock.withLock {
            let id = ObjectIdentifier(obj as AnyObject)
            let handle = rightMap[id] ?? {
                currentHandle += stride
                let handle = currentHandle
                leftMap[handle] = obj
                rightMap[id] = handle
                return handle
            }()
            counter[handle] = (counter[handle] ?? 0) + 1
            return handle
        }
    }

    func get(handle: Handle) -> T? {
        lock.withLock {
            leftMap[handle]
        }
    }

    func delete(handle: Handle) {
        remove(handle: handle)
    }

    @discardableResult
    func remove(handle: Handle) -> T? {
        lock.withLock {
            defer { counter[handle] = (counter[handle] ?? 1) - 1 }
            guard counter[handle] == 1 else { return leftMap[handle] }
            let obj = leftMap.removeValue(forKey: handle)
            if let obj = obj {
                rightMap.removeValue(forKey: ObjectIdentifier(obj as AnyObject))
            }
            return obj
        }
    }
}

// Magic number for the Rust proxy to call using the same mechanism as every other method,
// to free the callback once it's dropped by Rust.
private let IDX_CALLBACK_FREE: Int32 = 0

// Declaration and FfiConverters for ApplicationErrorReporter Callback Interface

public protocol ApplicationErrorReporter: AnyObject {
    func reportError(typeName: String, message: String)
    func reportBreadcrumb(message: String, module: String, line: UInt32, column: UInt32)
}

// The ForeignCallback that is passed to Rust.
private let foreignCallbackCallbackInterfaceApplicationErrorReporter: ForeignCallback =
    { (handle: Handle, method: Int32, args: RustBuffer, out_buf: UnsafeMutablePointer<RustBuffer>) -> Int32 in
        func invokeReportError(_ swiftCallbackInterface: ApplicationErrorReporter, _ args: RustBuffer) throws -> RustBuffer {
            defer { args.deallocate() }

            let reader = Reader(data: Data(rustBuffer: args))
            swiftCallbackInterface.reportError(
                typeName: try FfiConverterString.read(from: reader),
                message: try FfiConverterString.read(from: reader)
            )
            return RustBuffer()
            // TODO: catch errors and report them back to Rust.
            // https://github.com/mozilla/uniffi-rs/issues/351
        }
        func invokeReportBreadcrumb(_ swiftCallbackInterface: ApplicationErrorReporter, _ args: RustBuffer) throws -> RustBuffer {
            defer { args.deallocate() }

            let reader = Reader(data: Data(rustBuffer: args))
            swiftCallbackInterface.reportBreadcrumb(
                message: try FfiConverterString.read(from: reader),
                module: try FfiConverterString.read(from: reader),
                line: try FfiConverterUInt32.read(from: reader),
                column: try FfiConverterUInt32.read(from: reader)
            )
            return RustBuffer()
            // TODO: catch errors and report them back to Rust.
            // https://github.com/mozilla/uniffi-rs/issues/351
        }

        let cb = try! FfiConverterCallbackInterfaceApplicationErrorReporter.lift(handle)
        switch method {
        case IDX_CALLBACK_FREE:
            FfiConverterCallbackInterfaceApplicationErrorReporter.drop(handle: handle)
            // No return value.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 0
        case 1:
            let buffer = try! invokeReportError(cb, args)
            out_buf.pointee = buffer
            // Value written to out buffer.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 1
        case 2:
            let buffer = try! invokeReportBreadcrumb(cb, args)
            out_buf.pointee = buffer
            // Value written to out buffer.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 1

        // This should never happen, because an out of bounds method index won't
        // ever be used. Once we can catch errors, we should return an InternalError.
        // https://github.com/mozilla/uniffi-rs/issues/351
        default:
            // An unexpected error happened.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return -1
        }
    }

// FFIConverter protocol for callback interfaces
private enum FfiConverterCallbackInterfaceApplicationErrorReporter {
    // Initialize our callback method with the scaffolding code
    private static var callbackInitialized = false
    private static func initCallback() {
        try! rustCall { (err: UnsafeMutablePointer<RustCallStatus>) in
            ffi_errorsupport_b986_ApplicationErrorReporter_init_callback(foreignCallbackCallbackInterfaceApplicationErrorReporter, err)
        }
    }

    private static func ensureCallbackinitialized() {
        if !callbackInitialized {
            initCallback()
            callbackInitialized = true
        }
    }

    static func drop(handle: Handle) {
        handleMap.remove(handle: handle)
    }

    private static var handleMap = ConcurrentHandleMap<ApplicationErrorReporter>()
}

extension FfiConverterCallbackInterfaceApplicationErrorReporter: FfiConverter {
    typealias SwiftType = ApplicationErrorReporter
    // We can use Handle as the FFIType because it's a typealias to UInt64
    typealias FfiType = Handle

    static func lift(_ handle: Handle) throws -> SwiftType {
        ensureCallbackinitialized()
        guard let callback = handleMap.get(handle: handle) else {
            throw UniffiInternalError.unexpectedStaleHandle
        }
        return callback
    }

    static func read(from buf: Reader) throws -> SwiftType {
        ensureCallbackinitialized()
        let handle: Handle = try buf.readInt()
        return try lift(handle)
    }

    static func lower(_ v: SwiftType) -> Handle {
        ensureCallbackinitialized()
        return handleMap.insert(obj: v)
    }

    static func write(_ v: SwiftType, into buf: Writer) {
        ensureCallbackinitialized()
        buf.writeInt(lower(v))
    }
}

public func setApplicationErrorReporter(errorReporter: ApplicationErrorReporter) {
    try!

        rustCall {
            errorsupport_b986_set_application_error_reporter(
                FfiConverterCallbackInterfaceApplicationErrorReporter.lower(errorReporter), $0
            )
        }
}

/**
 * Top level initializers and tear down methods.
 *
 * This is generated by uniffi.
 */
public enum ErrorsupportLifecycle {
    /**
     * Initialize the FFI and Rust library. This should be only called once per application.
     */
    func initialize() {}
}
