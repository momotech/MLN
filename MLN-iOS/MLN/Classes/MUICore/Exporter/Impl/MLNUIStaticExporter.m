//
//  MLNUIStaticExporter.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIStaticExporter.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"
#import "MLNUIStaticExportProtocol.h"

@implementation MLNUIStaticExporter

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    Class<MLNUIStaticExportProtocol> exportClazz = (Class<MLNUIStaticExportProtocol>)clazz;
    const mlnui_objc_class *classInfo = [exportClazz mlnui_clazzInfo];
    return [self openlib:classInfo libName:classInfo->l_clz nativeClassName:classInfo->clz error:error];
}


- (BOOL)openlib:(const mlnui_objc_class *)libInfo libName:(const char *)libName nativeClassName:(const char *)nativeClassName error:(NSError **)error
{
    NSParameterAssert(libInfo != NULL);
    if (MLNUIHasSuperClass(libInfo)) {
        NSAssert(libInfo->supreClz != NULL, @"%s'super class must not be null!", libInfo->clz);
        Class<MLNUIStaticExportProtocol> superClass = NSClassFromString([NSString stringWithUTF8String:libInfo->supreClz]);
        if (![self openlib:[superClass mlnui_clazzInfo] libName:libName nativeClassName:nativeClassName error:error]) {
            return NO;
        }
    }
    return [self.luaCore openLib:libName nativeClassName:nativeClassName methodList:libInfo->clz_methods nup:0 leaveTableOnTop:NO error:error];
}

@end
