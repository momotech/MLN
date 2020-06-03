//
//  MLNUIBridge.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/6/1.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNUIBridge.h"
#import "MLNKit.h"
#import "MLNUIKit.h"
#import "NSObject+MLNUIReflect.h"

@interface MLNUIBridge ()
@property (nonatomic, strong) MLNUIViewController *tmpVC;
@property (nonatomic, weak) MLNLuaCore *luaCore;
@end

@implementation MLNUIBridge

- (MLNUIBridge *)initWithLuaCore:(MLNLuaCore *)luaCore fileName:(NSString *)fileName {
    if (!fileName || !luaCore) return self;
    
    MLNKitInstance *ki = MLN_KIT_INSTANCE(luaCore);
    self.luaCore = luaCore;
    if (![fileName hasSuffix:@".lua"]) {
        fileName = [fileName stringByAppendingString:@".lua"];
    }
    NSBundle *bundle = [NSBundle bundleWithPath:ki.currentBundle.bundlePath];
    MLNUIViewController *vc = [[MLNUIViewController alloc] initWithEntryFileName:fileName bundle:bundle];
    self.tmpVC = vc;
    return self;
}

- (MLNUIBridge *)display {
    UIViewController *superVC = MLN_KIT_INSTANCE(self.luaCore).viewController;
    [self.tmpVC mlnui_addToSuperViewController:superVC frame:superVC.view.bounds];
    return self;
}

- (MLNUIBridge *)bindForKey:(NSString *)key value:(NSObject *)value {
    if(!key) return self;
    NSObject *n = [value mlnui_convertToNativeObject];
    [self.tmpVC bindData:n forKey:key];
    return self;
}

LUA_EXPORT_BEGIN(MLNUIBridge)
LUA_EXPORT_METHOD(bind, "bindForKey:value:", MLNUIBridge)
LUA_EXPORT_METHOD(display, "display", MLNUIBridge)
LUA_EXPORT_END(MLNUIBridge, MLNUI, NO, NULL, "initWithLuaCore:fileName:")

//LUAUI_EXPORT_BEGIN(MLNUIBridge)
//LUAUI_EXPORT_METHOD(bind, "bindForKey:value:", MLNUIBridge)
//LUAUI_EXPORT_METHOD(build, "build", MLNUIBridge)
//LUAUI_EXPORT_END(MLNUIBridge, MLNUI, NO, NULL, "initWithLuaCore:fileName:")

@end
