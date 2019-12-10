//
//  MLNStaticExporter.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNStaticExporter.h"
#import "NSObject+MLNCore.h"
#import "MLNLuaCore.h"
#import "MLNStaticExportProtocol.h"

@implementation MLNStaticExporter

- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    Class<MLNStaticExportProtocol> exportClazz = (Class<MLNStaticExportProtocol>)clazz;
    const mln_objc_class *classInfo = [exportClazz mln_clazzInfo];
    return [self openlib:classInfo libName:classInfo->l_clz nativeClassName:classInfo->clz error:error];
}


- (BOOL)openlib:(const mln_objc_class *)libInfo libName:(const char *)libName nativeClassName:(const char *)nativeClassName error:(NSError **)error
{
    NSParameterAssert(libInfo != NULL);
    if (MLNHasSuperClass(libInfo)) {
        NSAssert(libInfo->supreClz != NULL, @"%s'super class must not be null!", libInfo->clz);
        Class<MLNStaticExportProtocol> superClass = NSClassFromString([NSString stringWithUTF8String:libInfo->supreClz]);
        if (![self openlib:[superClass mln_clazzInfo] libName:libName nativeClassName:nativeClassName error:error]) {
            return NO;
        }
    }
    return [self.luaCore openLib:libName nativeClassName:nativeClassName methodList:libInfo->clz_methods nup:0 error:error];
}

@end
