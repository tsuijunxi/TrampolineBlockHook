//
//  block_hook.m
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//

#import "block_hook.h"
#include "block_hook_private.h"
#include "trampoline_table.h"
#include "hash_map.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Block.h>
#include <dlfcn.h>

/* The ARM64 ABI does not require (or support) the _stret objc_msgSend variant */
#ifdef __arm64__
#define STRET_TABLE_REQUIRED 0
#define STRET_TABLE_CONFIG blockimp_table_page_config
#define STRET_TABLE blockimp_table
#else
#define STRET_TABLE_REQUIRED 1
#define STRET_TABLE_CONFIG blockimp_table_page_config
#define STRET_TABLE blockimp_table_stret
#endif



#pragma mark Trampolines

static trampoline_table *blockimp_table = NULL;

#if STRET_TABLE_REQUIRED
static trampoline_table *blockimp_table_stret = NULL;
#endif

static map_t global_map = NULL;

void set_dlinfo(void *block) {
    if (!block) {
        return;
    }
    if (!global_map) {
        global_map = hashmap_new();
    }
    if (!global_map) {
        return;
    }
    Dl_info *dlinfo = (Dl_info *)malloc(sizeof(Dl_info));
    if (!dlinfo) {
        return;
    }
    memset(dlinfo, 0, sizeof(*dlinfo));
    struct Block_layout *layout = (struct Block_layout *)block;
    if (dladdr(layout->invoke, dlinfo)) {
        hashmap_put(global_map, block, (void *)dlinfo);
    } else {
        free(dlinfo);
    }
}

void *get_dlinfo(void *block) {
    if (!global_map || !block) {
        return NULL;
    }
    Dl_info *dlinfo = NULL;
    hashmap_get(global_map, block, &dlinfo);
    return dlinfo;
}


BOOL hook_block_with_stub(void *block, void *replacement, void *pre, void *after) {
    if (!block || !replacement) {
        return NO;
    }
    set_dlinfo(block);
    struct Block_layout *bl = (struct Block_layout *)block;
    struct Block_layout *layoutReplaced = (struct Block_layout *)replacement;
    if (!bl->invoke || !bl->descriptor || !layoutReplaced->invoke) {
        return NO;
    }
    trampoline *tramp = NULL;
    if (bl->flags & BLOCK_USE_STRET) {
        tramp = trampoline_alloc(&STRET_TABLE_CONFIG, &STRET_TABLE);
    } else {
        tramp = trampoline_alloc(&blockimp_table_page_config, &blockimp_table);
    }
    if (!tramp || !tramp->trampoline) {
        return NO;
    }
    void **config = (void **)trampoline_data_ptr(tramp->trampoline);
    if (!config) {
        return NO;
    }
    config[0] = replacement;
    config[1] = tramp;
    config[2] = layoutReplaced->invoke;
    config[3] = pre;
    config[4] = after;
    bl->descriptor->reserved = (unsigned long)bl->invoke;
    bl->invoke = (void (*)(void *, ...))tramp->trampoline;
    
    
    return YES;
}

BOOL hook_block(void *block, void *replacement) {
    return hook_block_with_stub(block, replacement, NULL, NULL);
}

BOOL unhook_block(void *block) {
    if (!block) {
        return NO;
    }
    struct Block_layout *layout = (struct Block_layout *)block;
    if (!layout->invoke || !layout->descriptor || layout->descriptor->reserved == 0) {
        return NO;
    }
    void **config = trampoline_data_ptr(layout->invoke);
    if (!config) {
        return NO;
    }
    struct Block_layout *bl = (struct Block_layout *)config[0];
    trampoline *tramp = (trampoline *)config[1];
    if (!bl || !tramp) {
        return NO;
    }
    layout->invoke = (void (*)(void *, ...))layout->descriptor->reserved;
    layout->descriptor->reserved = 0;
    if (bl->flags & BLOCK_USE_STRET) {
        trampoline_free(&STRET_TABLE, tramp);
    } else {
        trampoline_free(&blockimp_table, tramp);
    }
    return YES;
}
