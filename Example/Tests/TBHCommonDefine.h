//
//  TBHCommonDefine.h
//  TrampolineBlockHook_Tests
//
//  Created by tsuijunxi on 28/2/2023.
//  Copyright © 2023 tsuijunxi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void pre(void *p1);

extern void after(void *p1);

extern void preMethodStub(Class cls, SEL sel);

extern void postMethodStub(Class cls, SEL sel);

typedef struct Student {
    int age;
    int grade;
    int math;
    int gem;
    int height;
    int shoes;
} Student;


@interface MyObject : NSObject
@property(nonatomic, copy) NSString *name;
@end
