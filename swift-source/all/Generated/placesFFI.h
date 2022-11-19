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

typedef int32_t (*ForeignCallback)(uint64_t, int32_t, RustBuffer, RustBuffer *_Nonnull);

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

void ffi_places_3c5d_SqlInterruptHandle_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_SqlInterruptHandle_interrupt(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void ffi_places_3c5d_PlacesApi_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull places_3c5d_PlacesApi_new_connection(
      void*_Nonnull ptr,RustBuffer conn_type,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesApi_register_with_sync_manager(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesApi_reset_history(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesApi_history_sync(
      void*_Nonnull ptr,RustBuffer key_id,RustBuffer access_token,RustBuffer sync_key,RustBuffer tokenserver_url,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesApi_bookmarks_sync(
      void*_Nonnull ptr,RustBuffer key_id,RustBuffer access_token,RustBuffer sync_key,RustBuffer tokenserver_url,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesApi_places_pinned_sites_import_from_fennec(
      void*_Nonnull ptr,RustBuffer db_path,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesApi_places_history_import_from_fennec(
      void*_Nonnull ptr,RustBuffer db_path,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesApi_places_bookmarks_import_from_fennec(
      void*_Nonnull ptr,RustBuffer db_path,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesApi_places_bookmarks_import_from_ios(
      void*_Nonnull ptr,RustBuffer db_path,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesApi_bookmarks_reset(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void ffi_places_3c5d_PlacesConnection_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull places_3c5d_PlacesConnection_new_interrupt_handle(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_latest_history_metadata_for_url(
      void*_Nonnull ptr,RustBuffer url,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_history_metadata_between(
      void*_Nonnull ptr,int64_t start,int64_t end,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_history_metadata_since(
      void*_Nonnull ptr,int64_t since,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_query_autocomplete(
      void*_Nonnull ptr,RustBuffer search,int32_t limit,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_accept_result(
      void*_Nonnull ptr,RustBuffer search_string,RustBuffer url,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_match_url(
      void*_Nonnull ptr,RustBuffer query,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_query_history_metadata(
      void*_Nonnull ptr,RustBuffer query,int32_t limit,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_history_highlights(
      void*_Nonnull ptr,RustBuffer weights,int32_t limit,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_note_history_metadata_observation(
      void*_Nonnull ptr,RustBuffer data,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_metadata_delete(
      void*_Nonnull ptr,RustBuffer url,RustBuffer referrer_url,RustBuffer search_term,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_metadata_delete_older_than(
      void*_Nonnull ptr,int64_t older_than,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_apply_observation(
      void*_Nonnull ptr,RustBuffer visit,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_visited_urls_in_range(
      void*_Nonnull ptr,int64_t start,int64_t end,int8_t include_remote,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_visit_infos(
      void*_Nonnull ptr,int64_t start_date,int64_t end_date,int32_t exclude_types,
    RustCallStatus *_Nonnull out_status
    );
int64_t places_3c5d_PlacesConnection_get_visit_count(
      void*_Nonnull ptr,int32_t exclude_types,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_visit_page(
      void*_Nonnull ptr,int64_t offset,int64_t count,int32_t exclude_types,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_visit_page_with_bound(
      void*_Nonnull ptr,int64_t bound,int64_t offset,int64_t count,int32_t exclude_types,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_visited(
      void*_Nonnull ptr,RustBuffer urls,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_delete_visits_for(
      void*_Nonnull ptr,RustBuffer url,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_delete_visits_between(
      void*_Nonnull ptr,int64_t start,int64_t end,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_delete_visit(
      void*_Nonnull ptr,RustBuffer url,int64_t timestamp,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_get_top_frecent_site_infos(
      void*_Nonnull ptr,int32_t num_items,RustBuffer threshold_option,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_wipe_local_history(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_delete_everything_history(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_prune_destructively(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_run_maintenance_prune(
      void*_Nonnull ptr,uint32_t db_size_limit,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_run_maintenance_vacuum(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_run_maintenance_optimize(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_run_maintenance_checkpoint(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_get_tree(
      void*_Nonnull ptr,RustBuffer item_guid,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_get_by_guid(
      void*_Nonnull ptr,RustBuffer guid,int8_t get_direct_children,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_get_all_with_url(
      void*_Nonnull ptr,RustBuffer url,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_search(
      void*_Nonnull ptr,RustBuffer query,int32_t limit,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_get_recent(
      void*_Nonnull ptr,int32_t limit,
    RustCallStatus *_Nonnull out_status
    );
int8_t places_3c5d_PlacesConnection_bookmarks_delete(
      void*_Nonnull ptr,RustBuffer id,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_bookmarks_delete_everything(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_get_url_for_keyword(
      void*_Nonnull ptr,RustBuffer keyword,
    RustCallStatus *_Nonnull out_status
    );
void places_3c5d_PlacesConnection_bookmarks_update(
      void*_Nonnull ptr,RustBuffer data,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_bookmarks_insert(
      void*_Nonnull ptr,RustBuffer bookmark,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer places_3c5d_PlacesConnection_places_history_import_from_ios(
      void*_Nonnull ptr,RustBuffer db_path,int64_t last_sync_timestamp,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull places_3c5d_places_api_new(
      RustBuffer db_path,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_places_3c5d_rustbuffer_alloc(
      int32_t size,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_places_3c5d_rustbuffer_from_bytes(
      ForeignBytes bytes,
    RustCallStatus *_Nonnull out_status
    );
void ffi_places_3c5d_rustbuffer_free(
      RustBuffer buf,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_places_3c5d_rustbuffer_reserve(
      RustBuffer buf,int32_t additional,
    RustCallStatus *_Nonnull out_status
    );
