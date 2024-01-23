//
//  HotReload.h
//  MLNDebugger
//
//  Created by MoMo on 2019/8/7.
//

#import <Foundation/Foundation.h>
#import <MLN/MLNKit.h>
//#import <MLN/MLNDebugHeader.h>
#import "MLNDevToolProtocol.h"

#define kLuaHotReloadHost  @"https://hotreload.com"

NS_ASSUME_NONNULL_BEGIN
@class MLNKitInstance;
@interface MLNHotReload : NSObject <MLNDevToolProtocol>

@property (nonatomic, copy) void(^registerBridgeClassesCallback)(MLNKitInstance *instance);
@property (nonatomic, copy) NSDictionary *(^extraInfoCallback)(NSDictionary *params);
@property (nonatomic, copy) void(^setupInstanceCallback)(MLNKitInstance *instance);
@property (nonatomic, copy) BOOL(^loadBridge)(MLNKitInstance *instance,NSString *bridgeName);
@property (nonatomic, copy) void(^updateCallback)(MLNKitInstance *instance);
@property (nonatomic, weak) UIViewController<MLNViewControllerProtocol> *viewController;
@property (nonatomic, copy, readonly) NSString *hotReloadBundlePath;
@property (nonatomic, copy, readonly) NSString *luaBundlePath;
@property (nonatomic, copy, readonly) NSString *entryFilePath;
@property (nonatomic, copy, readonly) NSString *relativeEntryFilePath;
@property (nonatomic, assign, getter=isOpenAssert) BOOL openAssert;

+ (void)openBreakpointDebugIfNeeded:(MLNKitInstance *)instance;

@end

NS_ASSUME_NONNULL_END
