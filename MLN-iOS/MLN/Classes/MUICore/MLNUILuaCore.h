//
//  MLNUICore.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import <Foundation/Foundation.h>
#import "MLNUIHeader.h"
#import "MLNUIExportProtocol.h"
#import "MLNUIErrorHandlerProtocol.h"
#import "MLNUIEntityExportProtocol.h"
#import "MLNUIConvertorProtocol.h"
#import "MLNUIExporterProtocol.h"
#import "MLNUILuaCoreDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaBundle;
@class MLNUILuaTable;
@class MLNUIExporter;
@interface MLNUILuaCore : NSObject <NSCopying>

/**
 lua状态机。
 */
@property (nonatomic, assign, readonly) lua_State *state;

/**
 强引用对象的lua table
 */
@property (nonatomic, strong, readonly) MLNUILuaTable *objStrongTable;

/**
 原生类的注册导出工具
 */
@property (nonatomic, strong, readonly) id<MLNUIExporterProtocol> exporter;

/**
 Lua 与Native的类型转换工具
 */
@property (nonatomic, strong, readonly) id<MLNUIConvertorProtocol> convertor;

/**
 代理对象
 */
@property (nonatomic, weak) id<MLNUILuaCoreDelegate> delegate;

/**
 当前执行的文件
 */
@property (nonatomic, copy, readonly) NSString *filePath;

/**
 当前lua core运行的lua bundle环境。
 */
@property (nonatomic, strong, readonly) MLNUILuaBundle *currentBundle;

/**
 错误处理句柄
 */
@property (nonatomic, weak) id<MLNUIErrorHandlerProtocol> errorHandler;

/**
 弱关联到该LuaCore的对象
 */
@property (nonatomic, weak) id weakAssociatedObject;

/**
 强关联到该LuaCore的对象
 */
@property (nonatomic, strong) id strongAssociatedObject;

/**
 初始化方法

 @param luaBundlePath Lua core运行的Lua bundle环境，为空时默认为Main Bundle
 @return Lua Core 实例
 */
- (instancetype)initWithLuaBundlePath:(NSString *__nullable)luaBundlePath;

/**
 初始化方法

 @param luaBundle Lua Core运行的Lua bundle环境, 为空时默认为Main Bundle
 @return Lua Core 实例
 */
- (instancetype)initWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle;

/**
 默认的初始化方法
 
 @param luaBundle Lua Core运行的Lua bundle环境，为空时默认为Main Bundle
 @param convertorClass Lua 与Native的类型转换工具的Class，为空时则使用默认的
 @param exporterClass 原生类的注册导出工具的Class，为空时则使用默认的
 @return Lua Core 实例
 */
- (instancetype)initWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle convertor:(Class<MLNUIConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNUIExporterProtocol> __nullable)exporterClass NS_DESIGNATED_INITIALIZER;

/**
 加载并执行文件

 @param filePath 要加载执行的文件
 @param error 错误信息
 @return 加载并执行是否成功
 */
- (BOOL)runFile:(NSString *)filePath error:(NSError **__nullable)error;

/**
 加载并执行数据

 @param data 要加载的数据
 @param name 数据对应的名称
 @param error 错误信息
 @return 加载并执行是否成功
 */
- (BOOL)runData:(NSData *)data name:(NSString *)name error:(NSError **__nullable)error;

/**
 加载文件到状态机栈顶

 @param filePath 待加载文件相对lua bundle的路径
 @param error 加载错误信息
 @return 加载是否成功
 */
- (BOOL)loadFile:(NSString *)filePath error:(NSError **__nullable)error;

/**
 将数据加载到状态机栈顶

 @param data 要加载的数据
 @param name 数据对应的名称
 @param error 加载错误信息
 @return 加载是否成功
 */
- (BOOL)loadData:(NSData *)data name:(NSString *)name error:(NSError **__nullable)error;

/**
 执行栈顶的Chunck或者function，参数位于栈顶以下的位置。

 @param argCount 参数个数
 @param error 执行错误信息
 @return 执行是否成功
 */
- (BOOL)call:(int)argCount error:(NSError **__nullable)error;

/**
执行栈顶的Chunck或者function，参数位于栈顶以下的位置。

@param argCount 参数个数
@param retCount 返回值个数
@param error 执行错误信息
@return 执行是否成功
*/
- (BOOL)call:(int)argCount retCount:(int)retCount error:(NSError **__nullable)error;

/**
 注册lib到状态机

 @param libName lib的名称
 @param list lib的方法列表
 @param nup upvalue 个数
 @param error 错误信息
 @return 册是否成功
 */
- (BOOL)openCLib:(const char * __nullable)libName methodList:(const luaL_Reg *)list nup:(int)nup error:(NSError ** __nullable)error;

/**
 注册lib到状态机

 @param libName lib的名称
 @param list lib的方法列表
 @param nup upvalue 个数
 @param leaveTable 是否把table留在栈顶.参考：luaL_openLib
 @param error 错误信息
 @return 注册是否成功
 */
- (BOOL)openLib:(nullable const char *)libName nativeClassName:(const char *)nativeClassName methodList:(const struct mlnui_objc_method *)list nup:(int)nup leaveTableOnTop:(BOOL)leaveTable error:(NSError **)error;

/**
 注册类到状态机
 
 @param clazz 要被注册的可导出类
 @param error 错误信息
 @return 导出是否成功
 */
- (BOOL)registerClazz:(Class<MLNUIExportProtocol>)clazz error:(NSError ** __nullable)error;

/**
 注册类到状态机

 @param classes 要被注册的可导出类
 @param error 错误信息
 @return 导出是否成功
 */
- (BOOL)registerClasses:(NSArray<Class<MLNUIExportProtocol>> *)classes error:(NSError ** __nullable)error;

/**
 注册全局函数到状态机

 @param cfunc 要注册的函数
 @param name 在lua中的名称
 @return 注册是否成功
 */
- (BOOL)registerGlobalFunc:(lua_CFunction)cfunc name:(const char *)name error:(NSError ** __nullable)error;

/**
 注册全局函数到状态机
 
 @param cfunc 要注册的函数
 @param name 在lua中的名称
 @param nup upvalue 个数
 @param error 错误信息
 @return 注册是否成功
 */
- (BOOL)registerGlobalFunc:(lua_CFunction)cfunc name:(const char *)name nup:(int)nup error:(NSError ** __nullable)error;

/**
 注册全局函数到状态机

 @param packageName 要注册的包名
 @param libname 表名称
 @param list 方法列表
 @param nup upvalue 个数
 @param error 错误信息
 @return 注册是否成功
 */
- (BOOL)registerGlobalFunc:(const char *)packageName libname:(const char *)libname methodList:(const struct mlnui_objc_method *)list nup:(int)nup error:(NSError ** __nullable)error;
- (BOOL)registerStaticFunc:(const char *)packageName libname:(const char *)libname methodList:(const struct mlnui_objc_method *)list nup:(int)nup error:(NSError ** __nullable)error;

/**
 注册全局变量

 @param value 全局变量的值
 @param globalName 全局变量的b名称
 @param error 错误信息
 @return 注册是否成功
 */
- (BOOL)registerGlobalVar:(id)value globalName:(NSString *)globalName error:(NSError ** __nullable)error;

/**
require lua file

@param lua_file lua file name
@return 是否成功
*/
- (BOOL)requireLuaFile:(const char *)lua_file;

/**
 创建元表

 @param name 元表名称
 @param error 错误信息
 @return 创建是否成功
 */
- (BOOL)createMetaTable:(const char *)name error:(NSError ** __nullable)error;

/**
 变更lua bundle环境

 @param bundlePath lua bundle的全路径
 */
- (void)changeLuaBundleWithPath:(NSString *)bundlePath;

/**
 变更lua bundle环境

 @param bundle 新的lua bundle
 */
- (void)changeLuaBundle:(MLNUILuaBundle *)bundle;

/**
 强引用对象
 
 @param objIndex 被强引用的对象在栈上的索引
 @param key 关联的key
 */
- (void)setStrongObjectWithIndex:(int)objIndex key:(NSString *)key;

/**
 强引用对象

 @param objIndex 被强引用的对象在栈上的索引
 @param cKey 关联的key
 */
- (void)setStrongObjectWithIndex:(int)objIndex cKey:(void *)cKey;

/**
 强引用对象
 
 @param obj 被强引用的对象
 @param key 关联的key
 */
- (void)setStrongObject:(id<MLNUIEntityExportProtocol>)obj key:(NSString *)key;

/**
 强引用对象
 
 @param obj 被强引用的对象
 @param cKey 关联的key
 */
- (void)setStrongObject:(id<MLNUIEntityExportProtocol>)obj cKey:(void *)cKey;

/**
 移除强引用对象
 
 @param key 关联的key
 */
- (void)removeStrongObject:(NSString *)key;

/**
 移除强引用对象
 
 @param cKey 关联的key
 */
- (void)removeStrongObjectForCKey:(void *)cKey;

/**
 将对应强引用对象压入栈顶
 
 @param key 关联的key
 */
- (BOOL)pushStrongObject:(NSString *)key;

/**
 将对应强引用对象压入栈顶
 
 @param cKey 关联的key
 */
- (BOOL)pushStrongObjectForCKey:(void *)cKey;

@end

@class MLNUIBlock;
@interface MLNUILuaCore (Stack)

/**
 将Native对象转换为Lua数据，并压入栈顶
 
 @param obj 要转换的Native对象
 @param error 错误信息学
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushNativeObject:(id)obj error:(NSError **__nullable)error;

/**
 将Native集合对象转换为Lua Table数据，并压入栈顶
 
 @param collection 要转换的Native集合对象(数组或字典)
 @param error 错误信息学
 @return 是否转换并压栈成功
 */
- (BOOL)pushLuaTable:(id)collection error:(NSError **__nullable)error;

/**
 将NSString转换为Lua的string，并压入栈顶
 
 @param aStr native的NSString字符串
 @param error 错误信息
 @return 是否转换并压栈成功
 */
- (BOOL)pushString:(NSString *)aStr error:(NSError **__nullable)error;

/**
 将Value对应的数据转换成多个lua值压栈，比如CGRect会被压栈为x,y,w,h四个number类型。
 
 @param value native的NSValue
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushValua:(NSValue *)value error:(NSError **__nullable)error;

/**
 将CGRect转换为Lua的Rect，并压入栈顶
 
 @param rect native的CGRect
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushCGRect:(CGRect)rect error:(NSError **__nullable)error;

/**
 将CGPoint转换为Lua的Point，并压入栈顶
 
 @param point native的CGPoint
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushCGPoint:(CGPoint)point error:(NSError **__nullable)error;

/**
 将CGSize转换为Lua的Size，并压入栈顶
 
 @param size native的CGSize
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushCGSize:(CGSize)size error:(NSError **__nullable)error;

/**
 尝试将指定位置的元素转换为相应的原生类型
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (id)toNativeObject:(int)idx error:(NSError **__nullable)error;

/**
 尝试将指定位置的元素转换为NSString
 
 @param idx lua 状态机上的位置
 @param error 错误信息学
 @return 是否转换并压栈成功
 */
- (NSString *)toString:(int)idx error:(NSError **__nullable)error;

/**
 尝试将指定位置的元素转换为CGRect
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (CGRect)toCGRect:(int)idx error:(NSError **__nullable)error;

/**
 尝试将指定位置的元素转换为CGPoint
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (CGPoint)toCGPoint:(int)idx error:(NSError **__nullable)error;

/**
 尝试将指定位置的元素转换为CGSize
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (CGSize)toCGSize:(int)idx error:(NSError **__nullable)error;

@end

@interface MLNUILuaCore (GC)

/**
 手动执行一次GC
 */
- (void)doGC;

@end

@interface MLNUILuaCore (Traceback)

/**
 获取调用栈的traceback

 @return 返回traceback信息
 */
- (NSString *)traceback;

/**
 获取调用栈的traceback条数

 @return 返回traceback信息
 */
- (int)tracebackCount;

@end

NS_ASSUME_NONNULL_END
