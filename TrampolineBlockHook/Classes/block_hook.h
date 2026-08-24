//
//  block_hook.h
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

BOOL hook_block(void *replaced, void *replacement);

BOOL unhook_block(void *replaced);

BOOL hook_block_with_stub(void *replaced, void *replacement, void *pre, void *post);

void *get_dlinfo(void *block);

#ifdef __cplusplus
}
#endif //__cplusplus
