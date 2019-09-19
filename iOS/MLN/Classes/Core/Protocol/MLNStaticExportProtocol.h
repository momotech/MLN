//
//  MLNStaticExport.h
//  MLNCore
//
//  Created by MoMo on 2019/7/24.
//

#ifndef MLNStaticExport_h
#define MLNStaticExport_h

#import "MLNExportProtocol.h"

@class MLNLuaCore;

/**
 静态导出协议
 */
@protocol MLNStaticExportProtocol <MLNExportProtocol>

/**
 被导出类的映射信息

 @return 映射信息
 */
+ (const mln_objc_class *)mln_clazzInfo;

/**
 调用当前静态bridge的LuaCore

 @return 当前调用者
 */
+ (MLNLuaCore *)mln_currentLuaCore;

/**
 更新调用当前静态bridge的LuaCore

 @param luaCore 当前调用者
 */
+ (void)mln_updateCurrentLuaCore:(MLNLuaCore *)luaCore;

@end

#endif /* MLNStaticExport_h */
