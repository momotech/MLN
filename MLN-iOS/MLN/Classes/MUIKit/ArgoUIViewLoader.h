//
//  ArgoUIViewLoader.h
//  ArgoUI
//
//  Created by xindong on 2021/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ArgoUIViewLoaderCallback)(NSString *keyPath, id newValue);

@interface ArgoUIViewLoader : NSObject

+ (void)preload:(NSUInteger)capacity;

+ (nullable UIView *)loadViewFromLuaFilePath:(NSString *)filePath modelKey:(NSString *)modelKey;

+ (void)dataUpdatedCallbackForView:(UIView *)view callback:(ArgoUIViewLoaderCallback)callback;

+ (void)updateData:(NSObject *)data forView:(UIView *)view autoWire:(BOOL)autoWire;

@end

NS_ASSUME_NONNULL_END
