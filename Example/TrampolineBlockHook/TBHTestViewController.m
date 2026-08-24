//
//  TBHTestViewController.m
//  TrampolineBlockHook_Example
//
//  Created by tsuijunxi on 22/2/2023.
//  Copyright © 2023 tsuijunxi. All rights reserved.
//

#import "TBHTestViewController.h"
#import <TrampolineBlockHook/block_hook.h>
#import <TrampolineBlockHook/method_hook.h>
#include <objc/runtime.h>

static void pre(id self, SEL sel, ...) {
    printf("pre hook\n");
}

static void after(id self, SEL sel, ...) {
    printf("after hook\n");
}

@interface TBHTestViewController ()

@end

@implementation TBHTestViewController

+ (void)load {
    hook_method_with_stub(TBHTestViewController.class, @selector(testMethod), @selector(testMethod), pre, after);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testMethod];
    [self testMethod:@"param1"];
    [self testWithBlock:^BOOL(NSString *param) {
        printf("this is testWithBlock callback. param = %s\n", param.UTF8String);
        return YES;
    }];
}

- (void)testMethod {
    printf("this is testMethod with return value.\n");
}

- (NSObject *)testMethod:(NSString *)param1 {
    printf("this is testMethod with return value and param:%s.\n", param1.UTF8String);
    return [NSObject new];
}

- (void)testWithBlock:(BOOL(^)(NSString *))block {
    printf("this is testWithBlock.\n");
    BOOL ret = NO;
    if (block) {
        ret = block(@"param1");
    }
    printf("this is result from block, ret = %d.\n", ret);
}


@end
