//
//  MLNGlobalFunction.h
//  AFNetworking
//
//  Created by MoMo on 2018/8/27.
//

#import <Foundation/Foundation.h>
#import <MLN/MLNKit.h>

@protocol MLNDebugPrintObserver <NSObject>

- (void)print:(NSString *)msg;

@end


@interface MLNDebugPrintFunction : NSObject <MLNGlobalFuncExportProtocol>

+ (void)addObserver:(id<MLNDebugPrintObserver>)observer;
+ (void)removeObserver:(id<MLNDebugPrintObserver>)observer;

@end
