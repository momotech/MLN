//
//  NSError+MLNUICore.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import <Foundation/Foundation.h>

#define kMLNUI_ERROR_DOMAIN   @"com.mln.error"
#define kMLNUI_ERROR_MSG      @"errorMessage"

typedef enum : NSInteger {
    /* lua 文件加载错误 */
    MLNUINSErrorCodeLoad = -1,
    /* lua 执行错误 */
    MLNUINSErrorCodeCall = -2,
    /* lua 状态机异常 */
    MLNUINSErrorCodeState = -3,
    /* lua 状态机注册异常 */
    MLNUINSErrorCodeOpenLib = -4,
    /* lua 转换异常 */
    MLNUINSErrorCodeConvert = -5,
} MLNUINSErrorCode;


NS_ASSUME_NONNULL_BEGIN

@interface NSError (MLNUICore)

/**
 创建文件加载错误

 @param msg 错误描述细信息
 @return error对象
 */
+ (instancetype)mlnui_errorLoad:(NSString *)msg;

/**
 lua执行错误

 @param msg 错误描述细信息
 @return error对象
 */
+ (instancetype)mlnui_errorCall:(NSString *)msg;

/**
 lua状态机错误

 @param msg 错误信息
 @return error对象
 */
+ (instancetype)mlnui_errorState:(NSString *)msg;

/**
 lua状态机注册错误

 @param msg 错误信息
 @return error对象
 */
+ (instancetype)mlnui_errorOpenLib:(NSString *)msg;

/**
 类型转换异常

 @param msg 错误信息
 @return error 对象
 */
+ (instancetype)mlnui_errorConvert:(NSString *)msg;

/**
 根据code和msg创建error对象
 
 @param code error code
 @param msg error的描述信息
 @return error 对象
 */
+ (instancetype)mlnui_error:(int)code msg:(NSString *)msg;

/**
 获取error信息

 @return error信息
 */
- (NSString *)mlnui_errorMessage;

@end

NS_ASSUME_NONNULL_END
