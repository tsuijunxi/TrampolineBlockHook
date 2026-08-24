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
    if (!global_map) {
        global_map = hashmap_new();
    }
    Dl_info *dlinfo = (Dl_info *)malloc(sizeof(Dl_info));
    memset(dlinfo, 0, sizeof(&dlinfo));
    struct Block_layout *layout = (struct Block_layout *)block;
    if (dladdr(layout->invoke, dlinfo)) {
        hashmap_put(global_map, block, (void *)dlinfo);
    }
}

void *get_dlinfo(void *block) {
    Dl_info *dlinfo;
    hashmap_get(global_map, block, &dlinfo);
    return dlinfo;
}


BOOL hook_block_with_stub(void *block, void *replacement, void *pre, void *after) {
    set_dlinfo(block);
    void *ret = get_dlinfo(block);
    trampoline *tramp;
    struct Block_layout *bl = (struct Block_layout *)block;
    if (bl->flags & BLOCK_USE_STRET) {
        tramp = trampoline_alloc(&STRET_TABLE_CONFIG, &STRET_TABLE);
    } else {
        tramp = trampoline_alloc(&blockimp_table_page_config, &blockimp_table);
    }
    struct Block_layout *layout = (struct Block_layout*)block;
    struct Block_layout *layoutReplaced = (struct Block_layout*)replacement;
    void **config = (void **)trampoline_data_ptr(tramp->trampoline);
    config[0] = replacement;
    config[1] = tramp;
    config[2] = layoutReplaced->invoke;
    config[3] = pre;
    config[4] = after;
//    layout->descriptor->reserved = (unsigned long)layout->invoke;
    layout->invoke = (void (*)(void *, ...))tramp->trampoline;
    
    
    return YES;
}

BOOL hook_block(void *block, void *replacement) {
    return hook_block_with_stub(block, replacement, NULL, NULL);
}

BOOL unhook_block(void *block) {
    struct Block_layout *layout = (struct Block_layout*)block;
    void **config = trampoline_data_ptr(layout->invoke);
    if (!config) {
        return NO;
    }
    struct Block_layout *bl = config[0];
    trampoline *tramp = config[1];
    layout->invoke = (void (*)(void *, ...))layout->descriptor->reserved;
    layout->descriptor->reserved = 0;
    if (bl->flags & BLOCK_USE_STRET) {
        trampoline_free(&STRET_TABLE, tramp);
    } else {
        trampoline_free(&blockimp_table, tramp);
    }
    return YES;
}

