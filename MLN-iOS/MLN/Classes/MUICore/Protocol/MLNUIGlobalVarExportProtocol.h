//
//  MLNUIGlobalVarExport.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/24.
//

#ifndef MLNUIGlobalVarExport_h
#define MLNUIGlobalVarExport_h

#import "MLNUIExportProtocol.h"

#define kGlobalVarLuaName @"kGlobalVarLuaName"
#define kGlobalVarMap @"kGlobalVarMap"

/**
 全局变量导出协议
 */
@protocol MLNUIGlobalVarExportProtocol <MLNUIExportProtocol>

/**
 全局变量的导出映射表

 @return 映射表
 */
+ (NSArray<NSDictionary *> *)mlnui_globalVarMap;

@end

#endif /* MLNUIGlobalVarExport_h */
