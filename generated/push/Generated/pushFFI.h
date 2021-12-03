// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

#pragma once

#include <stdbool.h>
#include <stdint.h>

// The following structs are used to implement the lowest level
// of the FFI, and thus useful to multiple uniffied crates.
// We ensure they are declared exactly once, with a header guard, UNIFFI_SHARED_H.
#ifdef UNIFFI_SHARED_H
    // We also try to prevent mixing versions of shared uniffi header structs.
    // If you add anything to the #else block, you must increment the version suffix in UNIFFI_SHARED_HEADER_V3
    #ifndef UNIFFI_SHARED_HEADER_V3
        #error Combining helper code from multiple versions of uniffi is not supported
    #endif // ndef UNIFFI_SHARED_HEADER_V3
#else
#define UNIFFI_SHARED_H
#define UNIFFI_SHARED_HEADER_V3
// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V3 in this file.           ⚠️

typedef struct RustBuffer
{
    int32_t capacity;
    int32_t len;
    uint8_t *_Nullable data;
} RustBuffer;

typedef RustBuffer (*ForeignCallback)(uint64_t, int32_t, RustBuffer);

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
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V3 in this file.           ⚠️
#endif // def UNIFFI_SHARED_H

void ffi_push_7ba2_PushManager_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull push_7ba2_PushManager_new(
      RustBuffer sender_id,RustBuffer server_host,RustBuffer http_protocol,RustBuffer bridge_type,RustBuffer registration_id,RustBuffer database_path,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer push_7ba2_PushManager_subscribe(
      void*_Nonnull ptr,RustBuffer channel_id,RustBuffer scope,RustBuffer app_server_sey,
    RustCallStatus *_Nonnull out_status
    );
int8_t push_7ba2_PushManager_unsubscribe(
      void*_Nonnull ptr,RustBuffer channel_id,
    RustCallStatus *_Nonnull out_status
    );
void push_7ba2_PushManager_unsubscribe_all(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
int8_t push_7ba2_PushManager_update(
      void*_Nonnull ptr,RustBuffer registration_token,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer push_7ba2_PushManager_verify_connection(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer push_7ba2_PushManager_decrypt(
      void*_Nonnull ptr,RustBuffer channel_id,RustBuffer body,RustBuffer encoding,RustBuffer salt,RustBuffer dh,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer push_7ba2_PushManager_dispatch_info_for_chid(
      void*_Nonnull ptr,RustBuffer channel_id,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_push_7ba2_rustbuffer_alloc(
      int32_t size,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_push_7ba2_rustbuffer_from_bytes(
      ForeignBytes bytes,
    RustCallStatus *_Nonnull out_status
    );
void ffi_push_7ba2_rustbuffer_free(
      RustBuffer buf,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_push_7ba2_rustbuffer_reserve(
      RustBuffer buf,int32_t additional,
    RustCallStatus *_Nonnull out_status
    );
