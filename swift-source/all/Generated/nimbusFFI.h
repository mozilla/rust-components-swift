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
typedef void (*UniFfiFutureCallbackUInt8)(const void * _Nonnull, uint8_t, RustCallStatus);
typedef void (*UniFfiFutureCallbackInt8)(const void * _Nonnull, int8_t, RustCallStatus);
typedef void (*UniFfiFutureCallbackUnsafeMutableRawPointer)(const void * _Nonnull, void*_Nonnull, RustCallStatus);
typedef void (*UniFfiFutureCallbackUnsafeMutableRawPointer)(const void * _Nonnull, void*_Nonnull, RustCallStatus);
typedef void (*UniFfiFutureCallbackUnsafeMutableRawPointer)(const void * _Nonnull, void*_Nonnull, RustCallStatus);
typedef void (*UniFfiFutureCallbackRustBuffer)(const void * _Nonnull, RustBuffer, RustCallStatus);

// Scaffolding functions
void uniffi_nimbus_fn_free_nimbusclient(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void*_Nonnull uniffi_nimbus_fn_constructor_nimbusclient_new(RustBuffer app_ctx, RustBuffer coenrolling_feature_ids, RustBuffer dbpath, RustBuffer remote_settings_config, RustBuffer available_randomization_units, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_initialize(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_get_experiment_branch(void*_Nonnull ptr, RustBuffer id, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_get_feature_config_variables(void*_Nonnull ptr, RustBuffer feature_id, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_get_experiment_branches(void*_Nonnull ptr, RustBuffer experiment_slug, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_get_active_experiments(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_get_enrollment_by_feature(void*_Nonnull ptr, RustBuffer feature_id, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_get_available_experiments(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
int8_t uniffi_nimbus_fn_method_nimbusclient_get_global_user_participation(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_set_global_user_participation(void*_Nonnull ptr, int8_t opt_in, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_fetch_experiments(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_set_fetch_enabled(void*_Nonnull ptr, int8_t flag, RustCallStatus *_Nonnull out_status
);
int8_t uniffi_nimbus_fn_method_nimbusclient_is_fetch_enabled(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_apply_pending_experiments(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_set_experiments_locally(void*_Nonnull ptr, RustBuffer experiments_json, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_reset_enrollments(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_opt_in_with_branch(void*_Nonnull ptr, RustBuffer experiment_slug, RustBuffer branch, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_opt_out(void*_Nonnull ptr, RustBuffer experiment_slug, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusclient_reset_telemetry_identifiers(void*_Nonnull ptr, RustBuffer new_randomization_units, RustCallStatus *_Nonnull out_status
);
void*_Nonnull uniffi_nimbus_fn_method_nimbusclient_create_targeting_helper(void*_Nonnull ptr, RustBuffer additional_context, RustCallStatus *_Nonnull out_status
);
void*_Nonnull uniffi_nimbus_fn_method_nimbusclient_create_string_helper(void*_Nonnull ptr, RustBuffer additional_context, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_record_event(void*_Nonnull ptr, RustBuffer event_id, int64_t count, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_record_past_event(void*_Nonnull ptr, RustBuffer event_id, int64_t seconds_ago, int64_t count, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_advance_event_time(void*_Nonnull ptr, int64_t by_seconds, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_clear_events(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_method_nimbusclient_dump_state_to_log(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_free_nimbustargetinghelper(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
int8_t uniffi_nimbus_fn_method_nimbustargetinghelper_eval_jexl(void*_Nonnull ptr, RustBuffer expression, RustCallStatus *_Nonnull out_status
);
void uniffi_nimbus_fn_free_nimbusstringhelper(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusstringhelper_string_format(void*_Nonnull ptr, RustBuffer template, RustBuffer uuid, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_nimbus_fn_method_nimbusstringhelper_get_uuid(void*_Nonnull ptr, RustBuffer template, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_nimbus_rustbuffer_alloc(int32_t size, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_nimbus_rustbuffer_from_bytes(ForeignBytes bytes, RustCallStatus *_Nonnull out_status
);
void ffi_nimbus_rustbuffer_free(RustBuffer buf, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_nimbus_rustbuffer_reserve(RustBuffer buf, int32_t additional, RustCallStatus *_Nonnull out_status
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_initialize(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_experiment_branch(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_feature_config_variables(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_experiment_branches(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_active_experiments(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_enrollment_by_feature(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_available_experiments(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_get_global_user_participation(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_set_global_user_participation(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_fetch_experiments(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_set_fetch_enabled(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_is_fetch_enabled(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_apply_pending_experiments(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_set_experiments_locally(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_reset_enrollments(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_opt_in_with_branch(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_opt_out(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_reset_telemetry_identifiers(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_create_targeting_helper(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_create_string_helper(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_record_event(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_record_past_event(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_advance_event_time(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_clear_events(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusclient_dump_state_to_log(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbustargetinghelper_eval_jexl(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusstringhelper_string_format(void
    
);
uint16_t uniffi_nimbus_checksum_method_nimbusstringhelper_get_uuid(void
    
);
uint16_t uniffi_nimbus_checksum_constructor_nimbusclient_new(void
    
);
uint32_t ffi_nimbus_uniffi_contract_version(void
    
);

