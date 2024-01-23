//
//  MLNLuaViewInstanceHandle.m
//  MLN
//
//  Created by xue.yunqiang on 2022/4/7.
//

#import "MLNLuaViewInstanceHandle.h"
#import "MLNImpoterManager.h"

@interface MLNLuaViewInstanceHandle()

@property(nonatomic, assign) BOOL isRegistGlobalVar;

@end

@implementation MLNLuaViewInstanceHandle

- (BOOL)instance:(MLNKitInstance *)instance loadBridge:(NSString *)bridgeName {
    if (!self.isRegistGlobalVar) {
        self.isRegistGlobalVar = !self.isRegistGlobalVar;
        [[MLNImpoterManager shared] registMLNglobalVarForInstance:instance];
    }
    return [[MLNImpoterManager shared] registBridge:bridgeName forInstance:instance];
}

@end
