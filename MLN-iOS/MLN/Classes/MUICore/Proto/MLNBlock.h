//
//  MLNBlock.h
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNLuaCore;
@class MLNLuaTable;

/**
 关联Lua Function的对象， 具体参数和返回值的转换规则，参阅MLNConvertor等
 
 @note ⚠️该类的实例化和方法调用都只能在主队列执行
 */
@interface MLNBlock : NSObject

/**
 Lua内核
 */
@property (nonatomic, weak, readonly) MLNLuaCore *luaCore;

/**
 创建Lua Function关联对象

 @param luaCore Lua内核
 @param index Lua Function在Lua栈上的位置
 @return Block对象
 */
- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore indexOnLuaStack:(int)index NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


/**
 调用当前Lua函数，如果需要传递参数，可以使用addXXXArgument系列方法

 @return 返回值
 */
- (id)callIfCan;

/**
 调用当前Lua函数传递一个参数

 @param aParam 参数
 @return 返回值
 */
- (id)callWithParam:(id)aParam;

/**
 添加obj类型参数
 
 @param argument obj类型参数
 */
- (void)addObjArgument:(id __nullable)argument;

/**
 添加int类型参数

 @param argument int类型参数
 */
- (void)addIntArgument:(int)argument;

/**
 添加float类型参数

 @param argument float类型参数
 */
- (void)addFloatArgument:(float)argument;

/**
 添加double类型参数

 @param argument double类型参数
 */
- (void)addDoubleArgument:(double)argument;

/**
 添加BOOL类型参数
 
 @param argument BOOL类型参数
 */
- (void)addBOOLArgument:(BOOL)argument;

/**
 添加NSInteger类型参数
 
 @param argument NSInteger类型参数
 */
- (void)addIntegerArgument:(NSInteger)argument;

/**
 添加NSUInteger类型参数
 
 @param argument NSUInteger类型参数
 */
- (void)addUIntegerArgument:(NSUInteger)argument;

/**
 添加CGRect类型参数
 
 @param argument CGRect类型参数
 */
- (void)addCGRectArgument:(CGRect)argument;


/**
 添加CGPoint类型参数
 
 @param argument CGPoint类型参数
 */
- (void)addCGPointArgument:(CGPoint)argument;

/**
 添加CGSize类型参数
 
 @param argument CGSize类型参数
 */
- (void)addCGSizeArgument:(CGSize)argument;

/**
 添加NSString类型参数
 
 @param argument NSString类型参数
 */
- (void)addStringArgument:(NSString * __nullable)argument;

/**
 添加Map类型参数，传入不可变类型会被转换为可变类型
 
 @param argument NSDictionary类型参数
 */
- (void)addMapArgument:(NSDictionary *)argument;

/**
 添加Array类型参数 传入不可变类型会被转换为可变类型
 
 @param argument NSArray类型参数
 */
- (void)addArrayArgument:(NSArray *)argument;

/**
 添加NSDictionary类型参数
 
 @param argument NSDictionary类型参数
 */
- (void)addLuaTableArgumentWithDictionary:(NSDictionary *)argument;

/**
 添加NSArray类型参数
 
 @param argument NSArray类型参数
 */
- (void)addLuaTableArgumentWithArray:(NSArray *)argument;

/**
 添加MLNLuaTable类型参数
 
 @param argument MLNLuaTable类型参数
 */
- (void)addLuaTableArgument:(MLNLuaTable *)argument;

@end

NS_ASSUME_NONNULL_END
