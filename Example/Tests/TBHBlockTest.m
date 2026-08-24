//
//  TBHArm64Test.m
//  TrampolineBlockHook_Tests
//
//  Created by tsuijunxi on 21/2/2023.
//  Copyright © 2023 tsuijunxi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TrampolineBlockHook/block_hook.h>
#import <TrampolineBlockHook/method_hook.h>
#include "TBHCommonDefine.h"

@interface TBHArm64Test : XCTestCase

@end

@implementation TBHArm64Test

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBatchedBlockReturnObjectWithAll {
    __block BOOL didRun = NO;
    for (int i = 0; i < 100; ++i) {
        MyObject *(^Block)() = ^MyObject * () {
            didRun = YES;
            printf("this is a trampoline structure return stret test, i = %d\n", i);
            MyObject *obj = [MyObject new];
            obj.name = @"original";
            return obj;
        };

        MyObject * (^ReplacedBlock)() = ^MyObject * () {
            //didRun = YES;
            printf("this is a trampoline structure return stret test, replaced,  i = %d\n", i);
            MyObject *obj = [MyObject new];
            obj.name = @"replaced";
            return obj;
            return nil;
        };

        hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), pre, after);
        MyObject *obj = Block();
        NSAssert([obj.name isEqualToString:@"replaced"], @"");
        
        unhook_block((__bridge void *)(Block));
        obj = Block();
        NSAssert([obj.name isEqualToString:@"original"], @"");
    }
}



- (void)testBlockReturnObjectWithAll {
    __block BOOL didRun = NO;
    MyObject *(^Block)(id self) = ^MyObject * (id blockself) {
        didRun = YES;
        printf("this is the original block\n");
        MyObject *obj = [MyObject new];
        obj.name = @"original";
        return obj;
    };

    MyObject * (^ReplacedBlock)(id self) = ^MyObject * (id blockself) {
        didRun = YES;
        printf("this is the replaced block\n");
        MyObject *obj = [MyObject new];
        obj.name = @"replaced";
        return obj;
    };

    hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), pre, after);
    MyObject *obj = Block(self);
    NSAssert([obj.name isEqualToString:@"replaced"], @"");
    
    unhook_block((__bridge void *)(Block));
    obj = Block(self);
    NSAssert([obj.name isEqualToString:@"original"], @"");
}

- (void)testBlockWithAll {
    __block BOOL didRun = NO;
    Student (^Block)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the original block\n");
        Student s = {1,2,3,4,5,6};
        return s;
    };

    Student (^ReplacedBlock)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the replaced block\n");
        Student s = {6,5,4,3,2,1};
        return s;
    };

    hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), pre, after);
    Student student = Block(self);
    NSAssert(student.height == 2, @"");

    unhook_block((__bridge void *)(Block));
    student = Block(self);
    NSAssert(student.height == 5, @"");
}

- (void)testBlockOnlyWithPre {
    __block BOOL didRun = NO;
    Student (^Block)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the original block\n");
        Student s = {1,2,3,4,5,6};
        return s;
    };
    Student (^ReplacedBlock)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the replaced block\n");
        Student s = {6,5,4,3,2,1};
        return s;
    };

    hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), pre, after);
    Student student = Block(self);
    NSAssert(student.height == 2, @"");

    unhook_block((__bridge void *)(Block));
    student = Block(self);
    NSAssert(student.height == 5, @"");
}

- (void)testBlockOnlyWithAfter {
    __block BOOL didRun = NO;
    Student (^Block)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the original block\n");
        Student s = {1,2,3,4,5,6};
        return s;
    };
    Student (^ReplacedBlock)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the replaced block\n");
        Student s = {6,5,4,3,2,1};
        return s;
    };

    hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), NULL, after);
    Student student = Block(self);
    NSAssert(student.height == 2, @"");

    unhook_block((__bridge void *)(Block));
    student = Block(self);
    NSAssert(student.height == 5, @"");
}

- (void)testBlockOnlyWithBlock {
    __block BOOL didRun = NO;
    Student (^Block)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the original block\n");
        Student s = {1,2,3,4,5,6};
        return s;
    };

    Student (^ReplacedBlock)(id self) = ^Student (id blockself) {
        didRun = YES;
        printf("this is the replaced block\n");
        Student s = {6,5,4,3,2,1};
        return s;
    };

    hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), NULL, NULL);
    Student student = Block(self);
    NSAssert(student.height == 2, @"");

    unhook_block((__bridge void *)(Block));
    student = Block(self);
    NSAssert(student.height == 5, @"");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
