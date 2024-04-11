//
//  MLNExporterProtocol.h
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#ifndef MLNExporterProtocol_h
#define MLNExporterProtocol_h

#import "MLNExportProtocol.h"

@class MLNLuaCore;

/**
 原生类的导出器工具协议
 */
@protocol MLNExporterProtocol <NSObject>

/**
 当前lua状态机
 */
@property (nonatomic, weak, readonly) MLNLuaCore *luaCore;

/**
 创建一个导出器
 
 @param luaCore lua状态机
 @return 导出器实例
 */
- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore;

/**
 导出一个类到lua状态机
 
 @param clazz 被导出的类
 @param error 错误信息学
 @return 是否导出成功
 */
- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError **)error;

@end

#endif /* MLNExporterProtocol_h */
