//
//  ArgoUIViewLoader.h
//  ArgoUI
//
//  Created by xindong on 2021/1/25.
//

#import <Foundation/Foundation.h>
#import <ArgoObservableMap.h>
#import <ArgoObservableArray.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN const char *ArgoUIViewLoaderKitInstanceInstanceKey;

typedef void(^ArgoUIViewLoaderCallback)(NSString *keyPath, id newValue);

@interface ArgoUIViewLoader : NSObject

/// 虚拟机预加载
/// @param capacity 预加载的虚拟机数量
+ (void)preload:(NSUInteger)capacity;

/// 加载lua脚本生成对应的view
/// @param filePath lua文件路径
/// @param modelKey ArgoUI文件中的model名字
+ (nullable UIView *)loadViewFromLuaFilePath:(NSString *)filePath modelKey:(NSString *)modelKey;

/// 加载lua脚本生成对应的view
/// @param filePath lua文件路径
/// @param modelKey ArgoUI文件中的model名字
/// @param error ArgoUI文件加载过程中的错误
+ (nullable UIView *)loadViewFromLuaFilePath:(NSString *)filePath
                                    modelKey:(nonnull NSString *)modelKey
                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 原生监听Lua中的数据变更
/// @param view 加载lua脚本返回的view
/// @param callback 数据变更的回调
+ (void)dataUpdatedCallbackForView:(UIView *)view callback:(ArgoUIViewLoaderCallback)callback;

/// 更新视图上的所有数据
/// @param data 数据，通常为NSDictionary
/// @param view 加载lua脚本返回的view
/// @param autoWire 是否执行lua中自动装配的函数
+ (void)updateData:(NSObject *)data forView:(UIView *)view autoWire:(BOOL)autoWire;

/// 更新视图上的所有数据
/// @param data 数据，通常为NSDictionary
/// @param view 加载lua脚本返回的view
/// @param autoWire 是否执行lua中自动装配的函数
/// @param error 更新视图上的所有数据时的错误
+ (void)updateData:(NSObject *)data
           forView:(UIView *)view
          autoWire:(BOOL)autoWire
             error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 获取view上的数据，修改该数据的某个字段可触发Lua中的UI更新
/// @param view 加载lua脚本返回的view
+ (ArgoObservableMap *)observableDataForView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
