//
//  MLNUIStaticFunctionExporter.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/7.
//

#import "MLNUIStaticFunctionExporter.h"
#import "NSError+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"

@implementation MLNUIStaticFunctionExporter

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    Class<MLNUIStaticFuncExportProtocol> exportClazz = (Class<MLNUIStaticFuncExportProtocol>)clazz;
    const mlnui_objc_class *clazzInfo = [exportClazz mlnui_clazzInfo];
    return [self.luaCore registerStaticFunc:clazzInfo->pkg libname:clazzInfo->l_clz methodList:clazzInfo->clz_methods nup:0 error:error];
}

@end
