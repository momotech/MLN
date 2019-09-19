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
    return [self openlib:classInfo error:error];
}

- (BOOL)openlib:(const mln_objc_class *)libInfo error:(NSError **)error
{
    if (MLNHasSuperClass(libInfo)) {
        Class<MLNStaticExportProtocol> superClass = NSClassFromString([NSString stringWithUTF8String:libInfo->supreClz]);
        if (![self openlib:[superClass mln_clazzInfo] error:error]) {
            return NO;
        }
    }
    return [self.luaCore openLib:libInfo->l_clz methodList:libInfo->clz_methods nup:0 error:error];
}

@end
