//
//  MLNMessageHandler.h
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/10.
//

#import <Foundation/Foundation.h>
#import "MLNServerListenerProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MLNServerManagerDelegate <NSObject>

/**
 刷新当前Lua展示内容

 @param bundlePath Lua运行的Bundle路径
 @param entryFilePath 入口文件名
 @param params 参数
 */
- (void)reload:(NSString * )bundlePath entryFilePath:(NSString * _Nonnull)entryFilePath params:(NSDictionary * _Nonnull )params;

@optional
- (void)startToGenerateCodeCoverageReportFile;

@end

@interface MLNServerManager : NSObject

@property (nonatomic, copy, readonly) NSString *hotReloadBundlePath;
@property (nonatomic, copy, readonly) NSString *luaBundlePath;
@property (nonatomic, copy, readonly) NSString *entryFilePath;
@property (nonatomic, copy, readonly) NSString *relativeEntryFilePath;

- (instancetype)initWithDelegate:(id<MLNServerManagerDelegate>)delegate listener:(id<MLNServerListenerProtocol>)listener;

- (void)restartUSBWithPort:(int)port;
- (void)startUSB;
- (int)currentUSBPort;

- (void)startNetWithIP:(NSString *)ip port:(int)port;

- (void)log:(NSString *)log;
- (void)error:(NSString *)error;


@end

NS_ASSUME_NONNULL_END
