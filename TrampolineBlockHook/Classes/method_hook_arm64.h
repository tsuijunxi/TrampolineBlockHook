//
//  method_hook_arm64.h
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 21/2/2023.
//

#if defined(__arm64__)

extern void *method_table_page;
extern struct trampoline_table_config method_table_page_config;

#endif
