//
//  MLNUIFileConst.m
//  MLNUI
//
//  Created by MoMo on 2019/7/1.
//

#import "MLNUIFileConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIFileConst

LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(FileInfo, (@{@"FileSize": kMLNUIFileSize,
                                   @"ModiDate": kMLNUIModiDate}))
LUAUI_EXPORT_GLOBAL_VAR_END()

@end
