//
//  trampoline_table.h
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//


#include <mach/mach.h>
#include <pthread.h>

typedef struct trampoline_table trampoline_table;
typedef struct trampoline trampoline;

/*
 * Trampoline table configuration
 */
typedef struct trampoline_table_config {
    /* The trampoline size */
    uint32_t trampoline_size;
    
    /* The page offset at which the trampolines are located. */
    uint32_t page_offset;

    /* The number of trampolines allocated per page. */
    uint32_t trampoline_count;

    /** The template code page. */
    void *template_page;
} trampoline_table_config;

/*
 * A double-linked list of trampoline table entries.
 */
struct trampoline_table {
    /* Table configuration */
    trampoline_table_config *config;

    /* Contigious writable and executable pages */
    vm_address_t data_page;
    vm_address_t trampoline_page;
    
    /* free list tracking */
    uint16_t free_count;
    trampoline *free_list;
    trampoline *free_list_pool;
    
    trampoline_table *prev;
    trampoline_table *next;
};

/*
 * A linked list of trampoline table entries.
 */
struct trampoline {
    /* The actual trampoline. */
    void *(*trampoline)(void);

    /** The table in which the entry is allocated. */
    trampoline_table *table;

    /* Next entry in the trampoline list. */
    trampoline *next;
};


/**
 * Allocate a new trampoline. Returns NULL on error.
 *
 * @param config The table configuration. This value is owned by the caller, and must survive for the lifetime of the table.
 * @param table_head The table from which the entry should be allocated.
 */
trampoline *trampoline_alloc (trampoline_table_config *config, trampoline_table **table_head);

/**
 * Deallocate a trampoline and return it to the free list.
 * 
 * @param table_head The root table from which the entry should be deallocated.
 * @param tramp The trampoline to deallocate.
 */
void trampoline_free (trampoline_table **table_head, trampoline *tramp);

/**
 * Given a trampoline's code pointer, return its associated data pointer.
 * @param code_ptr a trampoline's code pointer
 */
void *trampoline_data_ptr (void *code_ptr);
