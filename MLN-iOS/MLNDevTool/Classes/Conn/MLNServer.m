//
//  HotReloadServer.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "MLNServer.h"
#import "MLN_GCDAsyncSocket.h"
#import "PBCommandBuilder.h"
#import "LNEncoderFactory.h"
#import "LNClientFactory.h"
#import "LNTransporterFactory.h"

@interface MLNServer () <LNClientListener>

@property (nonatomic, strong) id<LNClientProtocol> netClient;
@property (nonatomic, strong) id<LNClientProtocol> usbClient;
@property (nonatomic, strong) id<LNClientProtocol> currentClient;

@property (nonatomic, weak) id<MLNNetworkReachabilityProtocol> networkHandler;
@property (nonatomic, weak) id<MLNServerListenerProtocol> listener;

@end

@implementation MLNServer

static MLNServer *sharedInstance;
+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [MLNServer new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)willEnterForeground:(NSNotification *)notification
{
    if (_usbClient.isRunning) {
        BOOL isReachable = [_usbClient isReachable];
        if (!isReachable) {
            [self stopUSB];
            NSLog(@"----------- willEnterForeground stop");
        } else {
            [self.listener server:self beginCheckUSBReachable:_usbClient.port];
            __weak typeof(self) wself = self;
            [_usbClient asyncCheckReachable:^(BOOL isReachable) {
                __strong typeof(wself) sself = wself;
                if (!isReachable) {
                    [sself stopUSB];
                }
                [sself.listener server:sself endCheckUSBReachable:sself->_usbClient.port isReachable:isReachable];
            }];
        }
    }
    if (_netClient.isRunning) {
        [_netClient isReachable];
    }
}

- (void)setup:(id<MLNServerListenerProtocol>)listener networkHandler:(nonnull id<MLNNetworkReachabilityProtocol>)networkHandler {
    self.listener = listener;
    [networkHandler addListener:^(BOOL isWifi) {
        if (!isWifi) {
            [self.netClient stop];
        }
    }];
    self.networkHandler = networkHandler;
}

- (void)startUSB:(int)port {
    [self startUsbClient:port];
}

- (void)restartUSBIfNeed:(int)port
{
    if (_usbClient.port == port && _usbClient.isReachable) {
        return;
    }
    [self stopUSB];
    [self startUSB:port];
}

- (void)stopUSB {
    if (_usbClient.isRunning) {
        [_usbClient stop];
    }
}

- (void)startNET:(NSString *)ip port:(int)port {
    [self startNetClient:ip port:port];
}

- (void)stopNET {
    if (_netClient.isRunning) {
        [_netClient stop];
    }
}

- (void)log:(NSString *)log entryFilePath:(NSString *)entryFilePath {
    [self.currentClient writeLog:log entryFilePath:entryFilePath];
}

- (void)error:(NSString *)error entryFilePath:(NSString *)entryFilePath {
    [self.currentClient writeError:error entryFilePath:entryFilePath];
}

- (void)reportCodeCoverageSummary:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSAssert1(fileData, @"The file data is nil when report lua code coverage summary.", filePath);
        if (fileData) {
            pbcoveragesummarycommand *cmd = [PBCommandBuilder buildCoverageSummaryCmd:fileData filePath:filePath];
            [self.currentClient writeData:cmd];
        }
    }
}

- (void)reportCodeCoverageDetail:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSAssert1(fileData, @"The file data is nil when report lua code coverage detail.", filePath);
        if (fileData) {
            pbcoveragedetailcommand *cmd = [PBCommandBuilder buildCoverageDetailCmd:fileData filePath:filePath];
            [self.currentClient writeData:cmd];
        }
    }
}

#pragma mark - Private
- (void)startNetClient:(NSString *)ip port:(int)port {
    
    if (![self.networkHandler isWifi]) {
        NSError *error= [NSError errorWithDomain:@"com.mlnserver" code:-1000 userInfo:@{@"errorMsg":@"请连接同一局域网内的WIFI"}];
        [self.listener server:self onDisconnected:ip port:port error:error];
        return;
    }
    if (_netClient.isRunning) {
        return;
    }
    _netClient = [LNClientFactory getClientWithIP:ip port:port listener:self];
    BOOL ret = [_netClient start];
    if (ret){
        __weak typeof(self) wself = self;
        [_netClient onMessage:^(id message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wself) sself = wself;
                // 重置当前客户端
                sself->_currentClient = sself->_netClient;
                [sself handle:message];
            });
        }];
    }
}

- (void)startUsbClient:(int)port {
    if (_usbClient.isRunning) {
        return;
    }
    _usbClient = [LNClientFactory getClientWithPort:port listener:self];
    BOOL ret = [_usbClient start];
    if (ret) {
        __weak typeof(self) wself = self;
        [_usbClient onMessage:^(id message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wself) sself = wself;
                // 重置当前客户端
                sself->_currentClient = sself->_usbClient;
                [sself handle:message];
            });
        }];
    }
}

- (void)handle:(id)message {
    [self.listener server:self onMessage:message];
}

#pragma mark - Setting
- (void)client:(id<LNClientProtocol>)client disconnectedWithError:(NSError *)error {
    [client stop];
    [self.listener server:self onDisconnected:client.ip port:client.port error:error];
}

- (void)clientOnConnected:(id<LNClientProtocol>)client {
    [self.listener server:self onConnected:client.ip port:client.port];
}

- (void)clientRequestForCertification:(id<LNClientProtocol>)client {
    [self.listener server:self onSyncDeviceInfo:client.ip port:client.port];
}

@end
