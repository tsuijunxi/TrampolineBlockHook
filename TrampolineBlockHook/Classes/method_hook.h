//
//  method_hook.h
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 21/2/2023.
//

extern BOOL hook_method(Class cls, SEL selector, SEL replacement);

extern BOOL hook_method_with_stub(Class cls, SEL selector, SEL replacement, void *pre, void *after);

extern BOOL unhook_method(Class cls, SEL selector);
