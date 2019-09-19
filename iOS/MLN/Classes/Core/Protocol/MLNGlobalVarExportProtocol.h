//
//  MLNGlobalVarExport.h
//  MLNCore
//
//  Created by MoMo on 2019/7/24.
//

#ifndef MLNGlobalVarExport_h
#define MLNGlobalVarExport_h

#import "MLNExportProtocol.h"

#define kGlobalVarLuaName @"kGlobalVarLuaName"
#define kGlobalVarMap @"kGlobalVarMap"

/**
 全局变量导出协议
 */
@protocol MLNGlobalVarExportProtocol <MLNExportProtocol>

/**
 全局变量的导出映射表

 @return 映射表
 */
+ (NSArray<NSDictionary *> *)mln_globalVarMap;

@end

#endif /* MLNGlobalVarExport_h */
