//
//  trampoline_table.m
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//

#import "trampoline_table.h"

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

static trampoline_table *trampoline_table_alloc (trampoline_table_config *config) {
    trampoline_table *table = NULL;
    while (table == NULL) {
        vm_address_t data_page = 0x0;
        kern_return_t kt;
        kt = vm_allocate (mach_task_self(), &data_page, PAGE_SIZE*2, VM_FLAGS_ANYWHERE);
        if (kt != KERN_SUCCESS) {
            fprintf(stderr, "vm_allocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
            break;
        }
        
        // drop the second half of the allocation to make room for the trampoline table
        vm_address_t trampoline_page = data_page+PAGE_SIZE;
        kt = vm_deallocate (mach_task_self(), trampoline_page, PAGE_SIZE);
        if (kt != KERN_SUCCESS) {
            fprintf(stderr, "vm_deallocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
            break;
        }
        
        vm_prot_t cur_prot;
        vm_prot_t max_prot;
        kt = vm_remap (mach_task_self(), &trampoline_page, PAGE_SIZE, 0x0, FALSE, mach_task_self(), (vm_address_t) config->template_page, FALSE, &cur_prot, &max_prot, VM_INHERIT_SHARE);
        
        /* If we lost access to the destination trampoline page, drop our config allocation mapping and retry */
        if (kt != KERN_SUCCESS) {
            /* Log unexpected failures */
            if (kt != KERN_NO_SPACE) {
                fprintf(stderr, "vm_remap() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
            }
            
            vm_deallocate (mach_task_self(), data_page, PAGE_SIZE);
            continue;
        }
        
        table = calloc (1, sizeof(trampoline_table));
        config->trampoline_count = (PAGE_SIZE - config->page_offset) / config->trampoline_size;
        table->free_count = config->trampoline_count;
        table->data_page = data_page;
        table->trampoline_page = trampoline_page;
        table->config = config;
    
        /* Create and initialize the free list */
        table->free_list_pool = calloc(config->trampoline_count, sizeof(trampoline));
        
        uint16_t i;
        for (i = 0; i < table->free_count; i++) {
            trampoline *entry = &table->free_list_pool[i];
            entry->table = table;
            entry->trampoline = (void *) (table->trampoline_page + (i * config->trampoline_size) + config->page_offset);

            if (i < table->free_count - 1)
                entry->next = &table->free_list_pool[i+1];
        }
        
        table->free_list = table->free_list_pool;
    }
    
    return table;
}

trampoline *trampoline_alloc(trampoline_table_config *config, trampoline_table **table_head) {
    pthread_mutex_lock(&lock);
    
    /* Check for an active trampoline table with available entries. */
    trampoline_table *table = *table_head;
    if (table == NULL || table->free_list == NULL) {
        table = trampoline_table_alloc (config);
        if (table == NULL) {
            return NULL;
        }
        
        /* Insert the new table at the top of the list */
        table->next = *table_head;
        if (table->next != NULL)
            table->next->prev = table;
        
        *table_head = table;
    }
    
    /* Claim the free entry */
    trampoline *entry = (*table_head)->free_list;
    (*table_head)->free_list = entry->next;
    (*table_head)->free_count--;
    entry->next = NULL;
    
    pthread_mutex_unlock(&lock);
    
    return entry;
}

void *trampoline_data_ptr (void *code_ptr) {
    return (uint8_t *) code_ptr - PAGE_SIZE;
}

void trampoline_free (trampoline_table **table_head, trampoline *tramp) {
    pthread_mutex_lock(&lock);
    
    /* Fetch the table references */
    trampoline_table *table = tramp->table;
    
    /* Return the entry to the free list */
    tramp->next = table->free_list;
    table->free_list = tramp;
    table->free_count++;
    
    /* If all trampolines within this table are free, and at least one other table exists, deallocate
     * the table */
    if (table->free_count == table->config->trampoline_count && *table_head != table) {
        /* Remove from the list */
        if (table->prev != NULL)
            table->prev->next = table->next;
        
        if (table->next != NULL)
            table->next->prev = table->prev;
        
        /* Deallocate pages */
        kern_return_t kt;
        kt = vm_deallocate (mach_task_self(), table->data_page, PAGE_SIZE);
        if (kt != KERN_SUCCESS)
            fprintf(stderr, "vm_deallocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
        
        kt = vm_deallocate (mach_task_self(), table->trampoline_page, PAGE_SIZE);
        if (kt != KERN_SUCCESS)
            fprintf(stderr, "vm_deallocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
        
        /* Deallocate free list */
        free (table->free_list_pool);
        free (table);
    } else if (*table_head != table) {
        /* Otherwise, bump this table to the top of the list */
        table->prev = NULL;
        table->next = *table_head;
        if (*table_head != NULL)
            (*table_head)->prev = table;
        
        *table_head = table;
    }
    
    pthread_mutex_unlock (&lock);
}

