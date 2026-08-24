//
//  block_hook_arm64_config.c
//  Pods
//
//  Created by tsuijunxi on 17/2/2023.
//

#ifndef block_hook_arm64_config_c
#define block_hook_arm64_config_c

#if defined(__x86_64__)

#include "trampoline_table.h"

extern void *method_table_page;
trampoline_table_config method_table_page_config = {
    .trampoline_size = 40,
    .page_offset = 0xA0,
    .trampoline_count = 500,
    .template_page = &method_table_page
};

#endif

#endif /* block_hook_arm64_config_c */
