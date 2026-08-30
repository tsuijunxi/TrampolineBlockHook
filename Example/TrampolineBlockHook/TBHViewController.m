//
//  TBHViewController.m
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 02/17/2023.
//  Copyright (c) 2023 tsuijunxi. All rights reserved.
//

#import "TBHViewController.h"
#import <TrampolineBlockHook/block_hook.h>
#include <objc/runtime.h>
#import <TrampolineBlockHook/method_hook.h>
#import <TrampolineBlockHook/block_hook_x86_64.h>
#import "TBHTestViewController.h"
#import <TrampolineBlockHook/block_hook_private.h>
#import "test.h"
#import <dlfcn.h>

static void pre(void *block) {
    printf("pre hook\n");
    Dl_info dlinfo;
    memset(&dlinfo, 0, sizeof(dlinfo));
//    if (dladdr(layout->descriptor->reserved, &dlinfo)) {
//        NSLog(@"%s be called before block object:%@", dlinfo.dli_sname, block);
//    }
}

static void after(void *block) {
    printf("after hook\n");
}

int add(int a, int b)
{
    return a + b;
}

typedef struct Student {
    int age;
    int grade;
    int math;
    int gem;
    int height;
    int shoes;
} Student;

Student testStruct() {
    Student s = {1,2,3,4,5,6};
    return s;
}

@interface TBHViewController ()

@end

@implementation TBHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    Student (^b1)(id self) = ^Student (id blockself) {
//        printf("original block\n");
//        Student s = {1,2,3,4,5,6};
//        return s;
//    };
//
//    Student (^b2)(id self) = ^Student (id blockself) {
//        printf("replaced block\n");
//        Student s = {1,2,3,4,5,6};
//        return s;
//    };
//
//    struct Block_layout *layout = (__bridge void *)b1;
//    struct Block_layout *layout2 = (__bridge void *)b2;
//    layout->invoke = layout2->invoke;
//    b1(self);
    
//    int ret = method1();
//    int r = add(1,2);

 
    Student (^Block)(id self) = ^Student (id blockself) {
        printf("this is the original block\n");
        Student s = {1,2,3,4,5,6};
        return s;
    };

    Student (^ReplacedBlock)(id self) = ^Student (id blockself) {
        printf("this is the replaced block\n");
        Student s = {6,5,4,3,2,1};
        return s;
    };

    hook_block_with_stub((__bridge void *)(Block), (__bridge void *)(ReplacedBlock), pre, after);
    Block(self);

    unhook_block((__bridge void *)(Block));
    Block(self);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIViewController *vc = [[TBHTestViewController alloc] init];
    [self pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
