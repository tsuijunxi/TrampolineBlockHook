//
//  method_hook.m
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 21/2/2023.
//

#import "method_hook.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#include "trampoline_table.h"
#include "method_hook_private.h"

static trampoline_table *method_table = NULL;

BOOL hook_method(Class cls, SEL selector, SEL replacement) {
    return hook_method_with_stub(cls, selector, replacement, NULL, NULL);
}

BOOL hook_method_with_stub(Class cls, SEL selector, SEL replacement, void *pre, void *after) {
    if (!cls || !selector || !replacement) {
        return NO;
    }
    Method origMethod = class_getInstanceMethod(cls, selector);
    if (!origMethod) return NO;
    
    IMP originIMP = method_getImplementation(origMethod);
    
    Method newMethod = class_getInstanceMethod(cls, replacement);
    if (!newMethod) return NO;
    IMP newIMP = method_getImplementation(newMethod);
    
    trampoline *tramp = trampoline_alloc(&method_table_page_config, &method_table);
    if (!tramp || !tramp->trampoline) return NO;

    void **config = (void **)trampoline_data_ptr(tramp->trampoline);
    if (!config) return NO;
    config[0] = originIMP;
    config[1] = tramp;
    config[2] = newIMP;
    config[3] = pre;
    config[4] = after;
    method_setImplementation(origMethod, (IMP)tramp->trampoline);
    return YES;
}

BOOL unhook_method(Class cls, SEL selector) {
    if (!cls || !selector) return NO;
    Method method = class_getInstanceMethod(cls, selector);
    if (!method) return NO;
    
    IMP currentIMP = method_getImplementation(method);
    void **config = trampoline_data_ptr(currentIMP);
    if (!config) return NO;
    IMP originIMP = (IMP)config[0];
    trampoline *tramp = (trampoline *)config[1];
    if (!originIMP || !tramp) return NO;
    method_setImplementation(method, originIMP);
    trampoline_free(&method_table, tramp);
    return YES;
}
