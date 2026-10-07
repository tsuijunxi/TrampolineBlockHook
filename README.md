# TrampolineBlockHook

[![CI Status](https://img.shields.io/travis/tsuijunxi/TrampolineBlockHook.svg?style=flat)](https://travis-ci.org/tsuijunxi/TrampolineBlockHook)
[![Version](https://img.shields.io/cocoapods/v/TrampolineBlockHook.svg?style=flat)](https://cocoapods.org/pods/TrampolineBlockHook)
[![License](https://img.shields.io/cocoapods/l/TrampolineBlockHook.svg?style=flat)](https://cocoapods.org/pods/TrampolineBlockHook)
[![Platform](https://img.shields.io/cocoapods/p/TrampolineBlockHook.svg?style=flat)](https://cocoapods.org/pods/TrampolineBlockHook)

TrampolineBlockHook is a lightweight Objective-C runtime hook library built around
trampolines. It can replace block invocations and Objective-C instance method
implementations, with optional callbacks before and after the replacement runs.

This project is intended for runtime research, debugging tools, instrumentation,
and mixed Objective-C/Swift projects that still expose Objective-C runtime entry
points. It is not a general-purpose Swift function hook library.

## Features

- Hook Objective-C blocks by replacing their `invoke` function.
- Hook Objective-C instance methods by installing a trampoline IMP.
- Register optional pre-hook and post-hook callbacks.
- Restore hooked blocks and methods with explicit unhook APIs.
- Includes arm64 and x86_64 trampoline implementations.

## Usage

### Hook a Block

```objc
#import <TrampolineBlockHook/block_hook.h>

void pre(void *block) {
    printf("before block\n");
}

void after(void *block) {
    printf("after block\n");
}

void (^originalBlock)(void) = ^{
    printf("original\n");
};

void (^replacementBlock)(void) = ^{
    printf("replacement\n");
};

hook_block_with_stub((__bridge void *)originalBlock,
                     (__bridge void *)replacementBlock,
                     pre,
                     after);

originalBlock();
unhook_block((__bridge void *)originalBlock);
```

### Hook a Method

```objc
#import <TrampolineBlockHook/method_hook.h>

hook_method_with_stub(MyClass.class,
                      @selector(originalMethod),
                      @selector(replacementMethod),
                      NULL,
                      NULL);

unhook_method(MyClass.class, @selector(originalMethod));
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 13.0+
- Objective-C / Objective-C++
- arm64 or x86_64

## Limitations

- Only Objective-C runtime entry points are supported.
- Swift methods must be exposed through Objective-C dispatch, such as `@objc dynamic`, to be hookable through the method API.
- Swift closures are not Objective-C blocks and are not supported by the block API unless they are bridged to Objective-C block objects.
- arm64e pointer authentication and newer platform hardening may require additional validation for production use.
- This library is low-level runtime infrastructure. Use it carefully and avoid applying it to security-sensitive or App Store-facing behavior without review.

## Installation

TrampolineBlockHook is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TrampolineBlockHook'
```

## Author

tsuijunxi, 598395670@qq.com

## Article

EN: [Hooking Objective-C Blocks with TrampolineHook on iOS](https://tsuijunxi.github.io/en/2023/05/08/center-redirection-in-ios/)

ZH: [如何用 Trampoline Hook 重定向 Objective-C Block](https://tsuijunxi.github.io/2023/05/08/%E8%81%8A%E8%81%8AiOS%E4%B8%AD%E7%9A%84%E4%B8%AD%E5%BF%83%E9%87%8D%E5%AE%9A%E5%90%91/)

## License

TrampolineBlockHook is available under the MIT license. See the LICENSE file for more info.
