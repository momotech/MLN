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
+ (const mln_objc_class *)mln_clazzInfo;

/**
 调用当前静态bridge的LuaCore

 @return 当前调用者
 */
+ (MLNUILuaCore *)mln_currentLuaCore;

/**
 更新调用当前静态bridge的LuaCore

 @param luaCore 当前调用者
 */
+ (void)mln_updateCurrentLuaCore:(MLNUILuaCore *)luaCore;

@end

#endif /* MLNUIStaticExport_h */
