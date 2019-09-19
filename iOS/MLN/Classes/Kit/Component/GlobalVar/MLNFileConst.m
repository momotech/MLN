//
//  MLNFileConst.m
//  MLN
//
//  Created by MoMo on 2019/7/1.
//

#import "MLNFileConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNFileConst

LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(FileInfo, (@{@"FileSize": kMILFileSize,
                                   @"ModiDate": kMILModiDate}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
