//
//  MLNKitBridgesManager.h
//  MLN
//
//  Created by MoMo on 2019/8/29.
//

#import <Foundation/Foundation.h>
#import "MLNExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNKitInstance;
@interface MLNKitBridgesManager : NSObject

/**
 承载Kit库bridge和LuaCore实例
 */
@property (nonatomic, weak, readonly) MLNKitInstance *instance;

- (instancetype)initWithUIInstance:(MLNKitInstance *)instance;

- (void)registerKit;
@end

NS_ASSUME_NONNULL_END
