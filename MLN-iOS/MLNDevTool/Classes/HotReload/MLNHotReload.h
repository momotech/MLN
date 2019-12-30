//
//  HotReload.h
//  MLNDebugger
//
//  Created by MoMo on 2019/8/7.
//

#import <Foundation/Foundation.h>
#import "MLNKit.h"
#import "MLNDevToolProtocol.h"
#define kLuaHotReloadHost  @"https://hotreload.com"

NS_ASSUME_NONNULL_BEGIN
@class MLNKitInstance;
@interface MLNHotReload : NSObject <MLNDevToolProtocol>

@property (nonatomic, copy) void(^registerBridgeClassesCallback)(MLNKitInstance *instance);
@property (nonatomic, copy) NSDictionary *(^extraInfoCallback)(void);
@property (nonatomic, copy) void(^setupInstanceCallback)(MLNKitInstance *instance);
@property (nonatomic, copy) void(^updateCallback)(MLNKitInstance *instance);
@property (nonatomic, weak) UIViewController<MLNViewControllerProtocol> *viewController;
@property (nonatomic, copy, readonly) NSString *hotReloadBundlePath;
@property (nonatomic, copy, readonly) NSString *luaBundlePath;
@property (nonatomic, copy, readonly) NSString *entryFilePath;
@property (nonatomic, copy, readonly) NSString *relativeEntryFilePath;

@end

NS_ASSUME_NONNULL_END
