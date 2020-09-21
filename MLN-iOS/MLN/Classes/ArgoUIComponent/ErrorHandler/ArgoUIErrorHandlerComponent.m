//
//  ArgoUIErrorHandlerComponent.m
//  ArgoUIComponent
//
//  Created by Dai on 2020/9/18.
//

#import "ArgoUIErrorHandlerComponent.h"

#if DEBUG && ArgoUI_Debugger_Pause_Enable
#include <sys/sysctl.h>
#include <unistd.h>

NS_INLINE int argo_debug_is_debugger_attached() {
  // See http://developer.apple.com/library/mac/#qa/qa1361/_index.html
  int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
  struct kinfo_proc info;
  size_t size = sizeof(info);
  return sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0) == 0 ?
      (info.kp_proc.p_flag & P_TRACED) != 0 : 0;
}
#define Argo_Pause(log) NSLog(@"%@",log); if(argo_debug_is_debugger_attached())raise(SIGSTOP)
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
