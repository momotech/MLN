//
//  MLNGlobalFuntionExporter.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNGlobalFuntionExporter.h"
#import "NSError+MLNCore.h"
#import "NSObject+MLNCore.h"
#import "MLNLuaCore.h"

@implementation MLNGlobalFuntionExporter

- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError **)error
{
    Class<MLNGlobalFuncExportProtocol> exportClazz = (Class<MLNGlobalFuncExportProtocol>)clazz;
    const mln_objc_class *clazzInfo = [exportClazz mln_clazzInfo];
    return [self.luaCore registerGlobalFunc:clazzInfo->pkg libname:clazzInfo->l_clz methodList:clazzInfo->clz_methods nup:0 error:error];
}

@end
