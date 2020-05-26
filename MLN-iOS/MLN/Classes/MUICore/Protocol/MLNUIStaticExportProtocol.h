//
//  MLNUIStaticExport.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/24.
//

#ifndef MLNUIStaticExport_h
#define MLNUIStaticExport_h

#import "MLNUIExportProtocol.h"

@class MLNUILuaCore;

/**
 静态导出协议
 */
@protocol MLNUIStaticExportProtocol <MLNUIExportProtocol>

/**
 被导出类的映射信息

 @return 映射信息
 */
+ (const mlnui_objc_class *)mlnui_clazzInfo;

/**
 调用当前静态bridge的LuaCore

 @return 当前调用者
 */
+ (MLNUILuaCore *)mlnui_currentLuaCore;

/**
 更新调用当前静态bridge的LuaCore

 @param luaCore 当前调用者
 */
+ (void)mlnui_updateCurrentLuaCore:(MLNUILuaCore *)luaCore;

@end

#endif /* MLNUIStaticExport_h */
