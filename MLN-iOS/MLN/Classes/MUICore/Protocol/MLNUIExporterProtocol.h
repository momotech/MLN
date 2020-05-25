//
//  MLNUIExporterProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#ifndef MLNUIExporterProtocol_h
#define MLNUIExporterProtocol_h

#import "MLNUIExportProtocol.h"

@class MLNUILuaCore;

/**
 原生类的导出器工具协议
 */
@protocol MLNUIExporterProtocol <NSObject>

/**
 当前lua状态机
 */
@property (nonatomic, weak, readonly) MLNUILuaCore *luaCore;

/**
 创建一个导出器
 
 @param luaCore lua状态机
 @return 导出器实例
 */
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore;

/**
 导出一个类到lua状态机
 
 @param clazz 被导出的类
 @param error 错误信息学
 @return 是否导出成功
 */
- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error;

@end

#endif /* MLNUIExporterProtocol_h */
