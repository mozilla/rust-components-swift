// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// The following structs are used to implement the lowest level
// of the FFI, and thus useful to multiple uniffied crates.
// We ensure they are declared exactly once, with a header guard, UNIFFI_SHARED_H.
#ifdef UNIFFI_SHARED_H
    // We also try to prevent mixing versions of shared uniffi header structs.
    // If you add anything to the #else block, you must increment the version suffix in UNIFFI_SHARED_HEADER_V4
    #ifndef UNIFFI_SHARED_HEADER_V4
        #error Combining helper code from multiple versions of uniffi is not supported
    #endif // ndef UNIFFI_SHARED_HEADER_V4
#else
#define UNIFFI_SHARED_H
#define UNIFFI_SHARED_HEADER_V4
// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️

typedef struct RustBuffer
{
    int32_t capacity;
    int32_t len;
    uint8_t *_Nullable data;
} RustBuffer;

typedef int32_t (*ForeignCallback)(uint64_t, int32_t, const uint8_t *_Nonnull, int32_t, RustBuffer *_Nonnull);

// Task defined in Rust that Swift executes
typedef void (*UniFfiRustTaskCallback)(const void * _Nullable);

// Callback to execute Rust tasks using a Swift Task
//
// Args:
//   executor: ForeignExecutor lowered into a size_t value
//   delay: Delay in MS
//   task: UniFfiRustTaskCallback to call
//   task_data: data to pass the task callback
typedef void (*UniFfiForeignExecutorCallback)(size_t, uint32_t, UniFfiRustTaskCallback _Nullable, const void * _Nullable);

typedef struct ForeignBytes
{
    int32_t len;
    const uint8_t *_Nullable data;
} ForeignBytes;

// Error definitions
typedef struct RustCallStatus {
    int8_t code;
    RustBuffer errorBuf;
} RustCallStatus;

// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️
#endif // def UNIFFI_SHARED_H

// Callbacks for UniFFI Futures
typedef void (*UniFfiFutureCallbackUnsafeMutableRawPointer)(const void * _Nonnull, void*_Nonnull, RustCallStatus);
typedef void (*UniFfiFutureCallbackUnsafeMutableRawPointer)(const void * _Nonnull, void*_Nonnull, RustCallStatus);
typedef void (*UniFfiFutureCallbackRustBuffer)(const void * _Nonnull, RustBuffer, RustCallStatus);

// Scaffolding functions
void uniffi_as_ohttp_client_fn_free_ohttpsession(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void*_Nonnull uniffi_as_ohttp_client_fn_constructor_ohttpsession_new(RustBuffer config, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_as_ohttp_client_fn_method_ohttpsession_encapsulate(void*_Nonnull ptr, RustBuffer method, RustBuffer scheme, RustBuffer server, RustBuffer endpoint, RustBuffer headers, RustBuffer payload, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_as_ohttp_client_fn_method_ohttpsession_decapsulate(void*_Nonnull ptr, RustBuffer encoded, RustCallStatus *_Nonnull out_status
);
void uniffi_as_ohttp_client_fn_free_ohttptestserver(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void*_Nonnull uniffi_as_ohttp_client_fn_constructor_ohttptestserver_new(RustCallStatus *_Nonnull out_status
    
);
RustBuffer uniffi_as_ohttp_client_fn_method_ohttptestserver_get_config(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_as_ohttp_client_fn_method_ohttptestserver_receive(void*_Nonnull ptr, RustBuffer message, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_as_ohttp_client_fn_method_ohttptestserver_respond(void*_Nonnull ptr, RustBuffer response, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_as_ohttp_client_rustbuffer_alloc(int32_t size, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_as_ohttp_client_rustbuffer_from_bytes(ForeignBytes bytes, RustCallStatus *_Nonnull out_status
);
void ffi_as_ohttp_client_rustbuffer_free(RustBuffer buf, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_as_ohttp_client_rustbuffer_reserve(RustBuffer buf, int32_t additional, RustCallStatus *_Nonnull out_status
);
uint16_t uniffi_as_ohttp_client_checksum_method_ohttpsession_encapsulate(void
    
);
uint16_t uniffi_as_ohttp_client_checksum_method_ohttpsession_decapsulate(void
    
);
uint16_t uniffi_as_ohttp_client_checksum_method_ohttptestserver_get_config(void
    
);
uint16_t uniffi_as_ohttp_client_checksum_method_ohttptestserver_receive(void
    
);
uint16_t uniffi_as_ohttp_client_checksum_method_ohttptestserver_respond(void
    
);
uint16_t uniffi_as_ohttp_client_checksum_constructor_ohttpsession_new(void
    
);
uint16_t uniffi_as_ohttp_client_checksum_constructor_ohttptestserver_new(void
    
);
uint32_t ffi_as_ohttp_client_uniffi_contract_version(void
    
);
