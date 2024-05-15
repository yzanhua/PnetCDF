// Copyright 2020 Joshua J Baker. All rights reserved.
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

#ifndef HASHMAP_H
#define HASHMAP_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C" {
#endif  // __cplusplus

struct hashmap;
typedef struct hashmap hashmap_t;

hashmap_t *hashmap_new (size_t elsize,
                             size_t cap,
                             uint64_t seed0,
                             uint64_t seed1,
                             uint64_t (*hash) (const void *item, uint64_t seed0, uint64_t seed1),
                             int (*compare) (const void *a, const void *b, void *udata),
                             void (*elfree) (void *item),
                             void *udata);

hashmap_t *hashmap_new_with_allocator (
    void *(*malloc) (size_t),
    void *(*realloc) (void *, size_t),
    void (*free) (void *),
    size_t elsize,
    size_t cap,
    uint64_t seed0,
    uint64_t seed1,
    uint64_t (*hash) (const void *item, uint64_t seed0, uint64_t seed1),
    int (*compare) (const void *a, const void *b, void *udata),
    void (*elfree) (void *item),
    void *udata);

void hashmap_free (hashmap_t *map);
void hashmap_clear (hashmap_t *map, bool update_cap);
size_t hashmap_count (hashmap_t *map);
bool hashmap_oom (hashmap_t *map);
const void *hashmap_get (hashmap_t *map, const void *item);
const void *hashmap_set (hashmap_t *map, const void *item);
const void *hashmap_delete (hashmap_t *map, const void *item);
const void *hashmap_probe (hashmap_t *map, uint64_t position);
bool hashmap_scan (hashmap_t *map, bool (*iter) (const void *item, void *udata), void *udata);
bool hashmap_iter (hashmap_t *map, size_t *i, void **item);

uint64_t hashmap_sip (const void *data, size_t len, uint64_t seed0, uint64_t seed1);
uint64_t hashmap_murmur (const void *data, size_t len, uint64_t seed0, uint64_t seed1);
uint64_t hashmap_xxhash3 (const void *data, size_t len, uint64_t seed0, uint64_t seed1);

const void *hashmap_get_with_hash (hashmap_t *map, const void *key, uint64_t hash);
const void *hashmap_delete_with_hash (hashmap_t *map, const void *key, uint64_t hash);
const void *hashmap_set_with_hash (hashmap_t *map, const void *item, uint64_t hash);
void hashmap_set_grow_by_power (hashmap_t *map, size_t power);
void hashmap_set_load_factor (hashmap_t *map, double load_factor);

// DEPRECATED: use `hashmap_new_with_allocator`
void hashmap_set_allocator (void *(*malloc) (size_t), void (*free) (void *));

#if defined(__cplusplus)
}
#endif  // __cplusplus

#endif  // HASHMAP_H
