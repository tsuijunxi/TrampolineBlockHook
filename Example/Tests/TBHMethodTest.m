//
//  TBHMethodTest.m
//  TrampolineBlockHook_Tests
//
//  Created by tsuijunxi on 28/2/2023.
//  Copyright © 2023 tsuijunxi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TrampolineBlockHook/block_hook.h>
#import <TrampolineBlockHook/method_hook.h>
#include "TBHCommonDefine.h"

@interface TBHMethodTest : XCTestCase

@end

@implementation TBHMethodTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called postMethodStub the invocation of each test method in the class.
}

- (void)testFloatMethodReturnObject {
//    hook_method_with_stub(self.class, @selector(addNumber1:withNumber2:), @selector(new_addNumber1:withNumber2:), preMethodStub, postMethodStub);
//    CGFloat ret = [self addNumber1:0.3 withNumber2:1.2];
//    NSAssert(fabs(ret - 1.4) < 0.00001f, @"");
//
//    unhook_method(self.class, @selector(addNumber1:withNumber2:));
//    ret = [self addNumber1:0.3 withNumber2:1.2];
//    NSAssert(fabs(ret - 1.5) < 0.00001f, @"");
}


- (void)testMethodReturnObject {
    hook_method_with_stub(self.class, @selector(returnObject), @selector(new_returnObject), NULL, NULL);
    MyObject *obj = [self returnObject];
    NSAssert([obj.name isEqualToString:@"replaced"], @"");

    unhook_method(self.class, @selector(returnObject));
    obj = [self returnObject];
    NSAssert([obj.name isEqualToString:@"original"], @"");
}


- (void)testMethodWithAll {
    hook_method_with_stub(self.class, @selector(printMethodList), @selector(new_printMethodList), preMethodStub, postMethodStub);
    BOOL ret = [self printMethodList];
    NSAssert(ret == NO, @"");

    unhook_method(self.class, @selector(printMethodList));
    ret = [self printMethodList];
    NSAssert(ret == YES, @"");
}

- (void)testMethodOnlyWithPre {
    hook_method_with_stub(self.class, @selector(printMethodList), @selector(new_printMethodList), preMethodStub, NULL);
    BOOL ret = [self printMethodList];
    NSAssert(ret == NO, @"");

    unhook_method(self.class, @selector(printMethodList));
    ret = [self printMethodList];
    NSAssert(ret == YES, @"");
}

- (void)testMethodOnlyWithAfter {
    hook_method_with_stub(self.class, @selector(printMethodList), @selector(new_printMethodList), NULL, postMethodStub);
    BOOL ret = [self printMethodList];
    NSAssert(ret == NO, @"");

    unhook_method(self.class, @selector(printMethodList));
    ret = [self printMethodList];
    NSAssert(ret == YES, @"");
}

- (void)testMethodOnlyWithMethod {
    hook_method_with_stub(self.class, @selector(printMethodList), @selector(new_printMethodList), NULL, NULL);
    BOOL ret = [self printMethodList];
    NSAssert(ret == NO, @"");

    unhook_method(self.class, @selector(printMethodList));
    ret = [self printMethodList];
    NSAssert(ret == YES, @"");
}

- (MyObject *)new_returnObject {
    MyObject *obj = [MyObject new];
    obj.name = @"replaced";
    return obj;
}

- (MyObject *)returnObject {
    MyObject *obj = [MyObject new];
    obj.name = @"original";
    return obj;
}

- (BOOL)new_printMethodList {
    printf("new_printMethodList\n");
    return NO;
}

- (BOOL)printMethodList {
    printf("printMethodList\n");
    return YES;
}

- (CGFloat)addNumber1:(CGFloat)number1 withNumber2:(CGFloat)number2 {
    return number1 + number2;
}

- (CGFloat)new_addNumber1:(CGFloat)number1 withNumber2:(CGFloat)number2 {
    return number1 + number2 - 0.1;
}

@end
