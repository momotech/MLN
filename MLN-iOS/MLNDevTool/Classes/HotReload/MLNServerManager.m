//
//  MLNMessageHandler.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/10.
//

#import "MLNServerManager.h"
#import <MLN/MLNKit.h>
#import "LNFileManager.h"
#import "MLNServer.h"
#import "PBCommandBuilder.h"
#import <MLN/MLNNetworkReachabilityManager.h>

#define kConnectErrorPortBeingUsedCode 48
#define kConnectErrorNetUnConnect -1000

#if TARGET_IPHONE_SIMULATOR//模拟器
#define kDefaultUSBPort 8173
#elif TARGET_OS_IPHONE//真机
#define kDefaultUSBPort 8174
#endif

#define kHotReloadUSBPort @"kHotReloadUSBPort"

#if DEBUG && 0
#include <sys/sysctl.h>
#include <unistd.h>
NS_INLINE int argo_debug_is_debugger_attached() {
  // See http://developer.apple.com/library/mac/#qa/qa1361/_index.html
  int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
  struct kinfo_proc info;
  size_t size = sizeof(info);
  return sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0) == 0 ?
      (info.kp_proc.p_flag & P_TRACED) != 0 : 0;
}
#define Argo_Pause(log) NSLog(@"%@",log); if(argo_debug_is_debugger_attached())raise(SIGSTOP)
#else
#define Argo_Pause(log)
#endif

@interface MLNServerManager () <MLNNetworkReachabilityProtocol, MLNServerListenerProtocol>

@property (nonatomic, weak, readonly) MLNServer *server;
@property (nonatomic, strong) LNFileManager *fileManager;
@property (nonatomic, strong) MLNNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, weak) id<MLNServerManagerDelegate> delegate;
@property (nonatomic, weak) id<MLNServerListenerProtocol> listener;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, copy) NSString *paramsStirng;
@property (nonatomic, assign) BOOL switchUSBPort;
@property (nonatomic, assign) int usbPort;
@property (nonatomic, copy) void(^networkChangedCallback)(BOOL isWifi);

@end
@implementation MLNServerManager

- (instancetype)initWithDelegate:(id<MLNServerManagerDelegate>)delegate listener:(nonnull id<MLNServerListenerProtocol>)listener {
    if (self = [super init]) {
        _delegate = delegate;
        _listener = listener;
        [self.server setup:self networkHandler:self];
    }
    return self;
}

- (void)log:(NSString *)log {
    [self.server log:log entryFilePath:self.entryFilePath];
}

- (void)error:(NSString *)error {
    Argo_Pause(error);
    [self.server error:error entryFilePath:self.entryFilePath];
}

- (void)restartUSBWithPort:(int)port {
    if (_usbPort != port) {
        _switchUSBPort = YES;
        _usbPort = port;
        [[NSUserDefaults standardUserDefaults] setInteger:port forKey:kHotReloadUSBPort];
        [self.server restartUSBIfNeed:port];
    }
}

- (void)startNetWithIP:(NSString *)ip port:(int)port {
    [self.server startNET:ip port:port];
}

- (void)startUSB
{
    [self.server startUSB:self.usbPort];
}

- (int)currentUSBPort
{
    return self.usbPort;
}

#pragma mark - MLNNetworkReachabilityProtocol
- (void)addListener:(nonnull void (^)(BOOL))callback {
    [self reachabilityManager];
    self.networkChangedCallback = callback;
}

- (BOOL)isWifi {
    return self.reachabilityManager.networkStatus == MLNNetworkStatusWifi;
}

#pragma mark - MLNServerListenerProtocol
- (void)reloadCMDFromServer:(MLNServer *)server {
    if (self.fileManager.luaBundlePath.length <= 0 || self.fileManager.relativeEntryFilePath.length <= 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(reload:entryFilePath:params:)]) {
        [self.delegate reload:self.fileManager.luaBundlePath entryFilePath:self.fileManager.relativeEntryFilePath params:self.params];
    }
}

- (void)server:(MLNServer *)server onConnected:(NSString *)ip port:(int)port {
    if ([self.listener respondsToSelector:@selector(server:onConnected:port:)]) {
        [self.listener server:server onConnected:ip port:port];
    }
    _switchUSBPort = NO;
}

- (void)server:(MLNServer *)server onDisconnected:(NSString *)ip port:(int)port error:(NSError *)error {
    int code = 0;
    NSString *msg = @"";
    if (error.code == kConnectErrorPortBeingUsedCode) {
        code = kConnectErrorPortBeingUsedCode;
        msg = @"端口已占用，请点击设置切换可用端口号";
    } else if(error.code == kConnectErrorNetUnConnect) {
        code = kConnectErrorNetUnConnect;
        msg = @"请连接同一局域网内的WIFI";
    } else {
        /**
         1.  当断开端口等于usb端口，且没有进行切换usb端口是，进行重连
         2. 切换新端口：disconnect端口是旧端口，与usbPort不一致，此时switchUSBPort为true,不需要重连，不需要提示
         **/
        if (error == nil && port == _usbPort && _switchUSBPort == NO)  {
            NSLog(@"----------- hotreload start USB");
            [server startUSB:_usbPort];
            return;
        } else if (!(port != _usbPort && _switchUSBPort == YES)) {
            code = -1;
            msg = @"连接断开";
        }
    }
    if ([self.listener respondsToSelector:@selector(server:onDisconnected:port:error:)]) {
        NSError *error = [NSError mln_error:code msg:msg];
        [self.listener server:server onDisconnected:ip port:port error:error];
    }
    _switchUSBPort = NO;
}

- (void)server:(MLNServer *)server beginCheckUSBReachable:(int)port {
    if ([self.listener respondsToSelector:@selector(server:beginCheckUSBReachable:)]) {
        [self.listener server:server beginCheckUSBReachable:port];
    }
}

- (void)server:(MLNServer *)server endCheckUSBReachable:(int)port isReachable:(BOOL)isReachable {
    if ([self.listener respondsToSelector:@selector(server:endCheckUSBReachable:isReachable:)]) {
        [self.listener server:server endCheckUSBReachable:port isReachable:isReachable];
    }
}

- (void)server:(MLNServer *)server updateEntryFile:(NSString *)entryFilePath relativeFilePath:(NSString *)relativeEntryFilePath params:(NSString *)params {
    [self updateParamsIfNeed:params];
    [self.fileManager updateEntryFilePath:entryFilePath relativeFilePath:relativeEntryFilePath];
    [self.fileManager updateLuaBundlePath];
}

- (void)server:(MLNServer *)server onSyncDeviceInfo:(NSString *)ip port:(int)port {
    if ([self.listener respondsToSelector:@selector(server:onSyncDeviceInfo:port:)]) {
        [self.listener server:server onSyncDeviceInfo:ip port:port];
    }
}

- (void)server:(MLNServer *)server onMessage:(id)message {
    if ([message isKindOfClass:[pbentryfilecommand class]]) {
        // 更新入口文件
        pbentryfilecommand *cmd = (pbentryfilecommand *)message;
        [self updateParamsIfNeed:cmd.params];
        [self.fileManager updateEntryFilePath:cmd.entryFilePath relativeFilePath:cmd.relativeEntryFilePath];
        [self.fileManager updateLuaBundlePath];
    } else if ([message isKindOfClass:[pbupdatecommand class]]) {
        // 更新指定文件
        pbupdatecommand *cmd = (pbupdatecommand *)message;
        BOOL ret = [self.fileManager updateFile:cmd.filePath relativeFilePath:cmd.relativeFilePath data:cmd.fileData];
        NSLog(@"|FILE| ==> %@更新%@", cmd.filePath, ret?@"成功":@"失败");
    } else if ([message isKindOfClass:[pbmovecommand class]]) {
        pbmovecommand *cmd = (pbmovecommand *)message;
        BOOL ret =  [self.fileManager moveFile:cmd.oldFilePath newFilePath:cmd.newFilePath];
        NSLog(@"|FILE| ==> %@移动到%@, %@", cmd.oldFilePath, cmd.newFilePath, ret?@"成功":@"失败");
    } else if ([message isKindOfClass:[pbrenamecommand class]]) {
        pbrenamecommand *cmd = (pbrenamecommand *)message;
        BOOL ret =  [self.fileManager renameFile:cmd.oldFilePath newFilePath:cmd.newFilePath];
        NSLog(@"|FILE| ==> %@重命名%@, %@", cmd.oldFilePath, cmd.newFilePath, ret?@"成功":@"失败");
    } else if ([message isKindOfClass:[pbremovecommand class]]) {
        pbremovecommand *cmd = (pbremovecommand *)message;
        BOOL ret =  [self.fileManager deleteFile:cmd.filePath];
        NSLog(@"|FILE| ==> %@删除, %@", cmd.filePath, ret?@"成功":@"失败");
    } else if ([message isKindOfClass:[pbcreatecommand class]]) {
        pbcreatecommand *cmd = (pbcreatecommand *)message;
        BOOL ret = [self.fileManager updateFile:cmd.filePath relativeFilePath:cmd.relativeFilePath data:cmd.fileData];
        NSLog(@"|FILE| ==> %@新建%@", cmd.filePath, ret?@"成功":@"失败");
    } else if ([message isKindOfClass:[pbreloadcommand class]]) {
        // reload
        if ([self.delegate respondsToSelector:@selector(reload:entryFilePath:params:)]) {
            [self.delegate reload:self.fileManager.luaBundlePath entryFilePath:self.fileManager.relativeEntryFilePath params:self.params];
        }
    } else if ([message isKindOfClass:[pbcoveragevisualcommand class]]) {
        [self.delegate startToGenerateCodeCoverageReportFile];
    }
    if ([self.listener respondsToSelector:@selector(server:onMessage:)]) {
        [self.listener server:server onMessage:message];
    }
}

- (void)updateParamsIfNeed:(NSString *)params {
    if (self.paramsStirng && [self.paramsStirng isEqualToString:params]) {
        return;
    }
    self.params = [self parseParams:params];
}

- (NSDictionary *)parseParams:(NSString *)params {
    if (!params || params.length <= 0) {
        return nil;
    }
    NSMutableDictionary *infos = [NSMutableDictionary dictionary];
    NSArray<NSString *> *keyValues = [params componentsSeparatedByString:@"&"];
    if (keyValues) {
        for (NSString *keyValue in keyValues) {
            NSArray<NSString *> *retArray = [keyValue componentsSeparatedByString:@"="];
            if (retArray.count == 2) {
                NSString *key = retArray.firstObject;
                NSString *value = retArray.lastObject;
                [infos setObject:value forKey:key];
            }
        }
    }
    return infos.copy;
}

#pragma mark - Getter
- (int)usbPort {
    if (_usbPort > 0) {
        return _usbPort;
    }
    NSNumber *num = [[NSUserDefaults standardUserDefaults] valueForKey:kHotReloadUSBPort];
    if (num) {
        _usbPort = [num intValue];
        return _usbPort;
    }
    _usbPort = kDefaultUSBPort;
    return _usbPort;
}

- (NSString *)entryFilePath {
    return self.fileManager.entryFilePath;
}

- (NSString *)relativeEntryFilePath {
    return self.fileManager.relativeEntryFilePath;
}

- (NSString *)luaBundlePath {
    return self.fileManager.luaBundlePath;
}

- (NSString *)hotReloadBundlePath {
    return self.fileManager.hotReloadBundlePath;
}

- (LNFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [[LNFileManager alloc] init];
    }
    return _fileManager;
}

- (MLNServer *)server {
    return [MLNServer getInstance];
}

- (MLNNetworkReachabilityManager *)reachabilityManager
{
    if (!_reachabilityManager) {
        _reachabilityManager = [MLNNetworkReachabilityManager manager];
        [_reachabilityManager startMonitoring];
        __weak typeof(self) wself = self;
        [_reachabilityManager addNetworkChangedCallback:^(MLNNetworkStatus status) {
            __strong typeof(wself) sself = wself;
            if (sself.networkChangedCallback) {
                sself.networkChangedCallback(status == MLNNetworkStatusWifi);
            }
        }];
    }
    return _reachabilityManager;
}

@end
