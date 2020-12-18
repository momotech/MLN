//
//  MLNUIKitInstance+DevToolDebug.m
//  MLNDevTool
//
//  Created by Dai Dongpeng on 2020/5/26.
//

#import "MLNUIKitInstance+DevToolDebug.h"
#import <objc/runtime.h>
#import "MLNHotReload.h"
#import <ArgoUI/MLNUIKit.h>

@implementation MLNUIKitInstance (DevToolDebug)

+ (void)load {
    SEL oldSel = @selector(runWithEntryFile:windowExtra:error:);
    SEL newSel = @selector(debug_runWithEntryFile:windowExtra:error:);
    
    Method oldMethod = class_getInstanceMethod([self class], oldSel);
    Method newMethod = class_getInstanceMethod([self class], newSel);
    
    IMP oldIMP = method_getImplementation(oldMethod);
    IMP newIMP = method_getImplementation(newMethod);
    
    const char *methodType = method_getTypeEncoding(class_getInstanceMethod([self class], oldSel));
    BOOL add = class_addMethod([self class], oldSel, newIMP, methodType);
    if (add) {
        class_replaceMethod([self class], newSel, oldIMP, methodType);
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

- (BOOL)debug_runWithEntryFile:(NSString *)entryFilePath windowExtra:(NSDictionary *)windowExtra error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (entryFilePath.length == 0) return NO;
//    [MLNHotReload openBreakpointDebugIfNeeded:self];

    PSTART(MLNUILoadTimeStatisticsType_Total);
    BOOL r = [self debug_runWithEntryFile:entryFilePath windowExtra:windowExtra error:error];
    PEND(MLNUILoadTimeStatisticsType_Total);
    PDISPLAY(2);
    return r;
}
@end
