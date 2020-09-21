//
//  MLNUIConvertorProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#ifndef MLNUIConvertorProtocol_h
#define MLNUIConvertorProtocol_h

#import <UIKit/UIkit.h>

@class MLNUILuaCore;
@protocol MLNUIConvertorProtocol <NSObject>

/**
 当前lua状态机
 */
@property (nonatomic, weak, readonly) MLNUILuaCore *luaCore;

/**
 创建转换器
 
 @param luaCore 当前lua状态机
 @return 转换器实例
 */
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore;

/**
 将Native对象转换为Lua数据，并压入栈顶
 
 @param obj 要转换的Native对象
 @param error 错误信息学
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushNativeObject:(id)obj error:(NSError **)error;

/**
 将Native集合对象转换为Lua Table数据，并压入栈顶
 
 @param collection 要转换的Native集合对象(数组或字典)
 @param error 错误信息学
 @return 是否转换并压栈成功
 */
- (BOOL)pushLuaTable:(id)collection error:(NSError **)error;

/**
 将NSString转换为Lua的string，并压入栈顶
 
 @param aStr native的NSString字符串
 @param error 错误信息
 @return 是否转换并压栈成功
 */
- (BOOL)pushString:(NSString *)aStr error:(NSError **)error;

/**
 将Value对应的数据转换成多个lua值压栈，比如CGRect会被压栈为x,y,w,h四个number类型。
 
 @param value native的NSValue
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushValua:(NSValue *)value error:(NSError **)error;

/**
 将CGRect转换为Lua的Rect，并压入栈顶
 
 @param rect native的CGRect
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushCGRect:(CGRect)rect error:(NSError **)error;

/**
 将CGPoint转换为Lua的Point，并压入栈顶
 
 @param point native的CGPoint
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushCGPoint:(CGPoint)point error:(NSError **)error;

/**
 将CGSize转换为Lua的Size，并压入栈顶
 
 @param size native的CGSize
 @param error 错误信息
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushCGSize:(CGSize)size error:(NSError **)error;

/**
 尝试将指定位置的元素转换为相应的原生类型
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (id)toNativeObject:(int)idx error:(NSError **)error;

/**
 尝试将指定位置的元素转换为NSString
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (NSString *)toString:(int)idx error:(NSError **)error;

/**
 尝试将指定位置的元素转换为CGRect
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (CGRect)toCGRect:(int)idx error:(NSError **)error;

/**
 尝试将指定位置的元素转换为CGPoint
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (CGPoint)toCGPoint:(int)idx error:(NSError **)error;

/**
 尝试将指定位置的元素转换为CGSize
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (CGSize)toCGSize:(int)idx error:(NSError **)error;

#pragma mark - ArgoBinding
/**
 和- (id)toNativeObject:(int)idx error:(NSError **)error
 的区别在于会将lua table转换成ArgoObservableMap or ArgoObservableArray
 
 @param idx lua 状态机上的位置
 @param error 错误信息
 @return 是否转换成功
 */
- (id)toArgoBindingNativeObject:(int)idx error:(NSError **)error;

/**
 将Native对象转换为Lua数据，并压入栈顶
 用于argo binding
 @param obj 要转换的Native对象
 @param error 错误信息学
 @return 数据被转化压栈的个数，0代表未成功
 */
- (int)pushArgoBindingNativeObject:(id)obj error:(NSError **)error;
@end

#endif /* MLNUIConvertorProtocol_h */
