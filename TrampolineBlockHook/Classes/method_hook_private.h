//
//  block_hook.h
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//

#pragma once

#if defined(__arm64__)
#include "method_hook_arm64.h"
#elif defined(__x86_64__)
#include "method_hook_x86_64.h"
#endif
