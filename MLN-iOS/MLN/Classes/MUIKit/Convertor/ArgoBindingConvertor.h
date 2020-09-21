//
//  ArgoBindingConvertor.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/2.
//

#import "MLNUIKiConvertor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoBindingConvertor : MLNUIKiConvertor

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

NS_ASSUME_NONNULL_END
