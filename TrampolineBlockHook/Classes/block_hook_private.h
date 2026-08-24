//
//  block_hook_private.h
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//

#pragma once

#if defined(__arm64__)
#include "block_hook_arm64.h"
#elif defined(__x86_64__)
#include "block_hook_x86_64.h"
#endif

/*
 * Block Flags
 */
typedef enum {
    /** 16-bit block reference count. */
    BLOCK_REFCOUNT_MASK =     (0xffff),
    
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    
    /** Helpers have C++ code. */
    BLOCK_HAS_CTOR =          (1 << 26),
    
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    
    /** Block returns its aggregate value in memory (ie, the block has a structure return type). */
    BLOCK_USE_STRET =         (1 << 29),
} block_flags_t;


struct Block_descriptor {
    /** Reserved value */
    unsigned long int reserved;
    
    /** Total size of the described block, including imported variables. */
    unsigned long int size;
    
    /** Optional block copy helper. May be NULL. */
    void (*copy)(void *dst, void *src);
    
    /** Optional block dispose helper. May be NULL. */
    void (*dispose)(void *);
};


struct Block_layout {
    /** Pointer to the block's Objective-C class. */
    void *isa;
    
    /** Block flags. */
    int flags;
    
    /** Reserved value. */
    int reserved;
    
    /** Block invocation function. */
    void (*invoke)(void *, ...);
    
    /** Shared block descriptor. */
    struct Block_descriptor *descriptor;
    
    // imported variables
};
