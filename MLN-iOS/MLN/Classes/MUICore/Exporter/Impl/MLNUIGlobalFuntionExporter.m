//
//  MLNUIGlobalFuntionExporter.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIGlobalFuntionExporter.h"
#import "NSError+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"

@implementation MLNUIGlobalFuntionExporter

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    Class<MLNUIGlobalFuncExportProtocol> exportClazz = (Class<MLNUIGlobalFuncExportProtocol>)clazz;
    const mln_objc_class *clazzInfo = [exportClazz mln_clazzInfo];
    return [self.luaCore registerGlobalFunc:clazzInfo->pkg libname:clazzInfo->l_clz methodList:clazzInfo->clz_methods nup:0 error:error];
}

@end
