//
//  MLNUIKitBridgesManager.h
//  MLNUI
//
//  Created by MoMo on 2019/8/29.
//

#import <Foundation/Foundation.h>
#import "MLNUIExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;
@interface MLNUIKitBridgesManager : NSObject

- (void)registerKitForLuaCore:(MLNUILuaCore *)luaCore;

@end

@class MLNUIKitInstance;
@interface MLNUIKitBridgesManager (Deprecated)
- (instancetype)initWithUIInstance:(MLNUIKitInstance *)instance;
- (void)registerKit;
@end
NS_ASSUME_NONNULL_END
