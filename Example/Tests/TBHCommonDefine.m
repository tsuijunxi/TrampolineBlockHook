//
//  TBHCommonDefine.m
//  TrampolineBlockHook_Tests
//
//  Created by tsuijunxi on 28/2/2023.
//  Copyright © 2023 tsuijunxi. All rights reserved.
//

#import "TBHCommonDefine.h"
#include <stdio.h>

void pre(void *p1) {
    printf("before hook: %p\n", p1);
}

void after(void *p1) {
    printf("after hook: %p\n", p1);
}

void preMethodStub(id obj, SEL sel) {
    NSLog(@"[PreMethodHook] obj = %@, sel = %@", obj, NSStringFromSelector(sel));
}

void postMethodStub(id obj, SEL sel) {
    NSLog(@"[PostMethodHook] obj = %@, sel = %@", obj, NSStringFromSelector(sel));
}

@implementation MyObject
@end
