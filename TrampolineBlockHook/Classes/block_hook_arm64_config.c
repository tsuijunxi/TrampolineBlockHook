//
//  block_hook_arm64_config.c
//  Pods
//
//  Created by tsuijunxi on 17/2/2023.
//

#ifndef block_hook_arm64_config_c
#define block_hook_arm64_config_c

#if defined(__arm64__)

#include "trampoline_table.h"

extern void *blockimp_table_page;
trampoline_table_config blockimp_table_page_config = {
    .trampoline_size = 40,
    .page_offset = 0xE8,
    .trampoline_count = 500,
    .template_page = &blockimp_table_page
};

#endif

#endif /* block_hook_arm64_config_c */
