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
            try! rustCall { ffi_places_219d_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_places_219d_rustbuffer_free(self, $0) }
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

// Types conforming to `Serializable` can be read and written in a bytebuffer.
private protocol Serializable {
    func write(into: Writer)
    static func read(from: Reader) throws -> Self
}

// Types confirming to `ViaFfi` can be transferred back-and-for over the FFI.
// This is analogous to the Rust trait of the same name.
private protocol ViaFfi: Serializable {
    associatedtype FfiType
    static func lift(_ v: FfiType) throws -> Self
    func lower() -> FfiType
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
private protocol Primitive {}

private extension Primitive {
    typealias FfiType = Self

    static func lift(_ v: Self) throws -> Self {
        return v
    }

    func lower() -> Self {
        return self
    }
}

// Types conforming to `ViaFfiUsingByteBuffer` lift and lower into a bytebuffer.
// Use this for complex types where it's hard to write a custom lift/lower.
private protocol ViaFfiUsingByteBuffer: Serializable {}

private extension ViaFfiUsingByteBuffer {
    typealias FfiType = RustBuffer

    static func lift(_ buf: RustBuffer) throws -> Self {
        let reader = Reader(data: Data(rustBuffer: buf))
        let value = try Self.read(from: reader)
        if reader.hasRemaining() {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    func lower() -> RustBuffer {
        let writer = Writer()
        write(into: writer)
        return RustBuffer(bytes: writer.bytes)
    }
}

// Implement our protocols for the built-in types that we use.

extension Optional: ViaFfiUsingByteBuffer, ViaFfi, Serializable where Wrapped: Serializable {
    fileprivate static func read(from buf: Reader) throws -> Self {
        switch try buf.readInt() as Int8 {
        case 0: return nil
        case 1: return try Wrapped.read(from: buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }

    fileprivate func write(into buf: Writer) {
        guard let value = self else {
            buf.writeInt(Int8(0))
            return
        }
        buf.writeInt(Int8(1))
        value.write(into: buf)
    }
}

extension Array: ViaFfiUsingByteBuffer, ViaFfi, Serializable where Element: Serializable {
    fileprivate static func read(from buf: Reader) throws -> Self {
        let len: Int32 = try buf.readInt()
        var seq = [Element]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try Element.read(from: buf))
        }
        return seq
    }

    fileprivate func write(into buf: Writer) {
        let len = Int32(count)
        buf.writeInt(len)
        for item in self {
            item.write(into: buf)
        }
    }
}

extension Int32: Primitive, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> Int32 {
        return try lift(buf.readInt())
    }

    fileprivate func write(into buf: Writer) {
        buf.writeInt(lower())
    }
}

extension Int64: Primitive, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> Int64 {
        return try lift(buf.readInt())
    }

    fileprivate func write(into buf: Writer) {
        buf.writeInt(lower())
    }
}

extension Double: Primitive, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> Double {
        return try lift(buf.readDouble())
    }

    fileprivate func write(into buf: Writer) {
        buf.writeDouble(lower())
    }
}

extension String: ViaFfi {
    fileprivate typealias FfiType = RustBuffer

    fileprivate static func lift(_ v: FfiType) throws -> Self {
        defer {
            try! rustCall { ffi_places_219d_rustbuffer_free(v, $0) }
        }
        if v.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: v.data!, count: Int(v.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    fileprivate func lower() -> FfiType {
        return utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                let bytes = ForeignBytes(bufferPointer: buf)
                return try! rustCall { ffi_places_219d_rustbuffer_from_bytes(bytes, $0) }
            }
        }
    }

    fileprivate static func read(from buf: Reader) throws -> Self {
        let len: Int32 = try buf.readInt()
        return String(bytes: try buf.readBytes(count: Int(len)), encoding: String.Encoding.utf8)!
    }

    fileprivate func write(into buf: Writer) {
        let len = Int32(utf8.count)
        buf.writeInt(len)
        buf.writeBytes(utf8)
    }
}

// Public interface members begin here.

// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.
public enum DocumentType {
    case regular
    case media
}

extension DocumentType: ViaFfiUsingByteBuffer, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> DocumentType {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .regular
        case 2: return .media
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    fileprivate func write(into buf: Writer) {
        switch self {
        case .regular:
            buf.writeInt(Int32(1))

        case .media:
            buf.writeInt(Int32(2))
        }
    }
}

extension DocumentType: Equatable, Hashable {}
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

public enum ErrorWrapper {
    // Simple error enums only carry a message
    case Wrapped(message: String)
}

extension ErrorWrapper: ViaFfiUsingByteBuffer, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> ErrorWrapper {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .Wrapped(
                message: try String.read(from: buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    fileprivate func write(into buf: Writer) {
        switch self {
        case let .Wrapped(message):
            buf.writeInt(Int32(1))
            message.write(into: buf)
        }
    }
}

extension ErrorWrapper: Equatable, Hashable {}

extension ErrorWrapper: Error {}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: {
        $0.deallocate()
        return UniffiInternalError.unexpectedRustCallError
    })
}

private func rustCallWithError<T, E: ViaFfiUsingByteBuffer & Error>(_: E.Type, _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: { try E.lift($0) })
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
            throw UniffiInternalError.rustPanic(try String.lift(callStatus.errorBuf))
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.rustPanic("Rust panic")
        }

    default:
        throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

public struct HistoryMetadataObservation {
    public var url: String
    public var referrerUrl: String?
    public var searchTerm: String?
    public var viewTime: Int32?
    public var documentType: DocumentType?
    public var title: String?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(url: String, referrerUrl: String? = nil, searchTerm: String? = nil, viewTime: Int32? = nil, documentType: DocumentType? = nil, title: String? = nil) {
        self.url = url
        self.referrerUrl = referrerUrl
        self.searchTerm = searchTerm
        self.viewTime = viewTime
        self.documentType = documentType
        self.title = title
    }
}

extension HistoryMetadataObservation: Equatable, Hashable {
    public static func == (lhs: HistoryMetadataObservation, rhs: HistoryMetadataObservation) -> Bool {
        if lhs.url != rhs.url {
            return false
        }
        if lhs.referrerUrl != rhs.referrerUrl {
            return false
        }
        if lhs.searchTerm != rhs.searchTerm {
            return false
        }
        if lhs.viewTime != rhs.viewTime {
            return false
        }
        if lhs.documentType != rhs.documentType {
            return false
        }
        if lhs.title != rhs.title {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(referrerUrl)
        hasher.combine(searchTerm)
        hasher.combine(viewTime)
        hasher.combine(documentType)
        hasher.combine(title)
    }
}

private extension HistoryMetadataObservation {
    static func read(from buf: Reader) throws -> HistoryMetadataObservation {
        return try HistoryMetadataObservation(
            url: String.read(from: buf),
            referrerUrl: String?.read(from: buf),
            searchTerm: String?.read(from: buf),
            viewTime: Int32?.read(from: buf),
            documentType: DocumentType?.read(from: buf),
            title: String?.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        url.write(into: buf)
        referrerUrl.write(into: buf)
        searchTerm.write(into: buf)
        viewTime.write(into: buf)
        documentType.write(into: buf)
        title.write(into: buf)
    }
}

extension HistoryMetadataObservation: ViaFfiUsingByteBuffer, ViaFfi {}

public struct HistoryMetadata {
    public var url: String
    public var title: String?
    public var previewImageUrl: String?
    public var createdAt: Int64
    public var updatedAt: Int64
    public var totalViewTime: Int32
    public var searchTerm: String?
    public var documentType: DocumentType
    public var referrerUrl: String?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(url: String, title: String?, previewImageUrl: String?, createdAt: Int64, updatedAt: Int64, totalViewTime: Int32, searchTerm: String?, documentType: DocumentType, referrerUrl: String?) {
        self.url = url
        self.title = title
        self.previewImageUrl = previewImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totalViewTime = totalViewTime
        self.searchTerm = searchTerm
        self.documentType = documentType
        self.referrerUrl = referrerUrl
    }
}

extension HistoryMetadata: Equatable, Hashable {
    public static func == (lhs: HistoryMetadata, rhs: HistoryMetadata) -> Bool {
        if lhs.url != rhs.url {
            return false
        }
        if lhs.title != rhs.title {
            return false
        }
        if lhs.previewImageUrl != rhs.previewImageUrl {
            return false
        }
        if lhs.createdAt != rhs.createdAt {
            return false
        }
        if lhs.updatedAt != rhs.updatedAt {
            return false
        }
        if lhs.totalViewTime != rhs.totalViewTime {
            return false
        }
        if lhs.searchTerm != rhs.searchTerm {
            return false
        }
        if lhs.documentType != rhs.documentType {
            return false
        }
        if lhs.referrerUrl != rhs.referrerUrl {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(title)
        hasher.combine(previewImageUrl)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
        hasher.combine(totalViewTime)
        hasher.combine(searchTerm)
        hasher.combine(documentType)
        hasher.combine(referrerUrl)
    }
}

private extension HistoryMetadata {
    static func read(from buf: Reader) throws -> HistoryMetadata {
        return try HistoryMetadata(
            url: String.read(from: buf),
            title: String?.read(from: buf),
            previewImageUrl: String?.read(from: buf),
            createdAt: Int64.read(from: buf),
            updatedAt: Int64.read(from: buf),
            totalViewTime: Int32.read(from: buf),
            searchTerm: String?.read(from: buf),
            documentType: DocumentType.read(from: buf),
            referrerUrl: String?.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        url.write(into: buf)
        title.write(into: buf)
        previewImageUrl.write(into: buf)
        createdAt.write(into: buf)
        updatedAt.write(into: buf)
        totalViewTime.write(into: buf)
        searchTerm.write(into: buf)
        documentType.write(into: buf)
        referrerUrl.write(into: buf)
    }
}

extension HistoryMetadata: ViaFfiUsingByteBuffer, ViaFfi {}

public struct HistoryHighlightWeights {
    public var viewTime: Double
    public var frequency: Double

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(viewTime: Double, frequency: Double) {
        self.viewTime = viewTime
        self.frequency = frequency
    }
}

extension HistoryHighlightWeights: Equatable, Hashable {
    public static func == (lhs: HistoryHighlightWeights, rhs: HistoryHighlightWeights) -> Bool {
        if lhs.viewTime != rhs.viewTime {
            return false
        }
        if lhs.frequency != rhs.frequency {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(viewTime)
        hasher.combine(frequency)
    }
}

private extension HistoryHighlightWeights {
    static func read(from buf: Reader) throws -> HistoryHighlightWeights {
        return try HistoryHighlightWeights(
            viewTime: Double.read(from: buf),
            frequency: Double.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        viewTime.write(into: buf)
        frequency.write(into: buf)
    }
}

extension HistoryHighlightWeights: ViaFfiUsingByteBuffer, ViaFfi {}

public struct HistoryHighlight {
    public var score: Double
    public var placeId: Int32
    public var url: String
    public var title: String?
    public var previewImageUrl: String?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(score: Double, placeId: Int32, url: String, title: String?, previewImageUrl: String?) {
        self.score = score
        self.placeId = placeId
        self.url = url
        self.title = title
        self.previewImageUrl = previewImageUrl
    }
}

extension HistoryHighlight: Equatable, Hashable {
    public static func == (lhs: HistoryHighlight, rhs: HistoryHighlight) -> Bool {
        if lhs.score != rhs.score {
            return false
        }
        if lhs.placeId != rhs.placeId {
            return false
        }
        if lhs.url != rhs.url {
            return false
        }
        if lhs.title != rhs.title {
            return false
        }
        if lhs.previewImageUrl != rhs.previewImageUrl {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(score)
        hasher.combine(placeId)
        hasher.combine(url)
        hasher.combine(title)
        hasher.combine(previewImageUrl)
    }
}

private extension HistoryHighlight {
    static func read(from buf: Reader) throws -> HistoryHighlight {
        return try HistoryHighlight(
            score: Double.read(from: buf),
            placeId: Int32.read(from: buf),
            url: String.read(from: buf),
            title: String?.read(from: buf),
            previewImageUrl: String?.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        score.write(into: buf)
        placeId.write(into: buf)
        url.write(into: buf)
        title.write(into: buf)
        previewImageUrl.write(into: buf)
    }
}

extension HistoryHighlight: ViaFfiUsingByteBuffer, ViaFfi {}

public struct Dummy {
    public var md: [HistoryMetadata]?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(md: [HistoryMetadata]?) {
        self.md = md
    }
}

extension Dummy: Equatable, Hashable {
    public static func == (lhs: Dummy, rhs: Dummy) -> Bool {
        if lhs.md != rhs.md {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(md)
    }
}

private extension Dummy {
    static func read(from buf: Reader) throws -> Dummy {
        return try Dummy(
            md: [HistoryMetadata]?.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        md.write(into: buf)
    }
}

extension Dummy: ViaFfiUsingByteBuffer, ViaFfi {}

public func placesGetLatestHistoryMetadataForUrl(handle: Int64, url: String) throws -> HistoryMetadata? {
    let _retval = try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_get_latest_history_metadata_for_url(handle.lower(), url.lower(), $0)
        }
    return try HistoryMetadata?.lift(_retval)
}

public func placesGetHistoryMetadataBetween(handle: Int64, start: Int64, end: Int64) throws -> [HistoryMetadata] {
    let _retval = try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_get_history_metadata_between(handle.lower(), start.lower(), end.lower(), $0)
        }
    return try [HistoryMetadata].lift(_retval)
}

public func placesGetHistoryMetadataSince(handle: Int64, start: Int64) throws -> [HistoryMetadata] {
    let _retval = try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_get_history_metadata_since(handle.lower(), start.lower(), $0)
        }
    return try [HistoryMetadata].lift(_retval)
}

public func placesQueryHistoryMetadata(handle: Int64, query: String, limit: Int32) throws -> [HistoryMetadata] {
    let _retval = try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_query_history_metadata(handle.lower(), query.lower(), limit.lower(), $0)
        }
    return try [HistoryMetadata].lift(_retval)
}

public func placesGetHistoryHighlights(handle: Int64, weights: HistoryHighlightWeights, limit: Int32) throws -> [HistoryHighlight] {
    let _retval = try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_get_history_highlights(handle.lower(), weights.lower(), limit.lower(), $0)
        }
    return try [HistoryHighlight].lift(_retval)
}

public func placesNoteHistoryMetadataObservation(handle: Int64, data: HistoryMetadataObservation) throws {
    try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_note_history_metadata_observation(handle.lower(), data.lower(), $0)
        }
}

public func placesMetadataDelete(handle: Int64, url: String, referrerUrl: String?, searchTerm: String?) throws {
    try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_metadata_delete(handle.lower(), url.lower(), referrerUrl.lower(), searchTerm.lower(), $0)
        }
}

public func placesMetadataDeleteOlderThan(handle: Int64, olderThan: Int64) throws {
    try

        rustCallWithError(ErrorWrapper.self) {
            places_219d_places_metadata_delete_older_than(handle.lower(), olderThan.lower(), $0)
        }
}