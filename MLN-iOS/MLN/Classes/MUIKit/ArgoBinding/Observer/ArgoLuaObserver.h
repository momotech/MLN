//
//  ArgoLuaObserver.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/29.
//

#import "ArgoObserverBase.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUIBlock;
@interface ArgoLuaObserver : ArgoObserverBase

@property (nonatomic, strong, readonly) MLNUIBlock *block;

+ (instancetype)observerWithBlock:(MLNUIBlock *)block callback:(nullable ArgoBlockChange)callback keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
