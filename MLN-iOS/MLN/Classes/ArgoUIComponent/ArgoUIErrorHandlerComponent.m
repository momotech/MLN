//
//  ArgoUIErrorHandlerComponent.m
//  ArgoUIComponent
//
//  Created by Dai on 2020/9/18.
//

#import "ArgoUIErrorHandlerComponent.h"

#if DEBUG
#define Argo_Pause(log) NSLog(@"%@",log); raise(SIGSTOP)
#else
#define Argo_Pause(log)
#endif

@implementation ArgoUIErrorHandlerComponent

- (BOOL)canHandleAssert:(MLNUIKitInstance *)instance {
    return YES;
}

- (void)instance:(MLNUIKitInstance *)instance error:(NSString *)error {
    Argo_Pause(error);
}

- (void)instance:(MLNUIKitInstance *)instance luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback {
    Argo_Pause(error);
}

@end
