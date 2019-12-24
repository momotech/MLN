//
//  HotReloadServer.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "MLNServerListenerProtocol.h"
#import "MLNNetworkReachabilityProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNServer : NSObject

@property (nonatomic, copy, readonly) NSString *hotReloadBundlePath;

+ (instancetype)getInstance;

- (void)setup:(id<MLNServerListenerProtocol>)listener networkHandler:(id<MLNNetworkReachabilityProtocol>)networkHandler;

- (void)startUSB:(int)port;
- (void)restartUSBIfNeed:(int)port;
- (void)stopUSB;

- (void)startNET:(NSString *)ip port:(int)port;
- (void)stopNET;

- (void)log:(NSString *)log entryFilePath:(NSString *)entryFilePath;
- (void)error:(NSString *)error entryFilePath:(NSString *)entryFilePath;

- (void)reportCodeCoverageSummary:(NSString *)filePath;
- (void)reportCodeCoverageDetail:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
