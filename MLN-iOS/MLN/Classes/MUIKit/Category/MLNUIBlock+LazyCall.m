//
//  MLNUIBlock+LazyCall.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/20.
//

#import "MLNUIBlock+LazyCall.h"
#import "MLNUIHeader.h"
#import "MLNUIExtScope.h"
#import "MLNUIKitHeader.h"
#import "MLNUILazyBlockTask.h"

@implementation MLNUIBlock (LazyCall)

- (void)lazyCallIfCan:(void(^)(id))completionBlock {
    @weakify(self);

    doInMainQueue
    (
#if OCPERF_COALESCE_BLOCK
     @strongify(self);
     if(!self) return;
     
     NSArray *args = self->_arguments.copy;
      [self reset];
      MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE(self.luaCore);
      MLNUILazyBlockTask *task = [MLNUILazyBlockTask taskWithCallback:^{
         @strongify(self);
         if (!self) return;
         id r = [self callWithArguments:args];
         if (completionBlock) {
             completionBlock(r);
         }
     } taskID:self.innerFunction];
      [instance forcePushLazyTask:task];
#else
     [self callIfCan];
#endif
     )
}


@end
