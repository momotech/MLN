//
//  HotReload.m
//  MLNDebugger
//
//  Created by MoMo on 2019/8/7.
//

#import "MLNHotReload.h"
#import "MLNServer.h"
#import "PBCommandBuilder.h"
#import "MLNDebugPrintFunction.h"
#import "MLNDebugCodeCoverageFunction.h"
#import "NSDictionary+MLNSafety.h"
#import "MLNHotReloadPresenter.h"
#import "MLNServerManager.h"
#import "MLNKitInstanceFactory.h"

@interface MLNHotReload () <MLNKitInstanceErrorHandlerProtocol, MLNKitInstanceDelegate, MLNServerManagerDelegate, MLNDebugPrintObserver, MLNServerListenerProtocol, MLNHotReloadPresenterDelegate> {
    int _usbPort;
    BOOL _running;
    BOOL _defaultIdleTimeStatus;
}

@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, strong) UIView *luaContentView;
@property (nonatomic, strong) UIView *benchLuaContentView;
@property (nonatomic, strong) MLNKitInstance *luaInstance;
@property (nonatomic, strong) MLNKitInstance *benchLuaInstance;
@property (nonatomic, copy, readonly) NSDictionary *extraInfo;

@property (nonatomic, strong) MLNHotReloadPresenter *presenter;
@property (nonatomic, strong) MLNServerManager *serverManager;

@end

@implementation MLNHotReload

@synthesize isUtilViewControllerShow = _isUtilViewControllerShow;

static MLNHotReload *sharedInstance;
+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [MLNHotReload new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _serverManager = [[MLNServerManager alloc] initWithDelegate:self listener:self];
        _presenter = [[MLNHotReloadPresenter alloc] init];
        _presenter.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [MLNDebugPrintFunction addObserver:self];
    }
    return self;
}

- (void)willEnterForeground:(NSNotification *)notification
{
   [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)startWithRootView:(UIView *)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    if (_running) {
        return;
    }
    // 不息屏
    _defaultIdleTimeStatus = [UIApplication sharedApplication].idleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    _running = YES;
    self.rootView = rootView;
    self.viewController = viewController;
    self.luaContentView = [[UIView alloc] initWithFrame:rootView.bounds];
    self.luaContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.benchLuaContentView = [[UIView alloc] initWithFrame:rootView.bounds];
    self.benchLuaContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.presenter openUI];
    [self.serverManager startUSB];
}

- (void)stop
{
    [self.presenter closeUI];
    _running = NO;
    self.luaInstance = nil;
    self.benchLuaInstance = nil;
    self.luaContentView = nil;
    self.benchLuaContentView = nil;
}

- (void)error:(NSString *)error
{
    [self.server error:error entryFilePath:self.entryFilePath];
}

- (void)log:(NSString *)log
{
    [self.server log:log entryFilePath:self.entryFilePath];
}

- (void)doLuaViewDidAppear
{
    [self.luaInstance doLuaWindowDidAppear];
}

- (void)doLuaViewDidDisappear
{
    [self.luaInstance doLuaWindowDidDisappear];
    [UIApplication sharedApplication].idleTimerDisabled = _defaultIdleTimeStatus;
}

- (MLNKitInstance *)createLuaInstance:(NSString * )bundlePath entryFilePath:(NSString * _Nonnull)entryFilePath params:(NSDictionary * _Nonnull )params
{
    MLNKitInstance *luaInstance = [[MLNKitInstanceFactory defaultFactory] createKitInstanceWithViewController:self.viewController];
    luaInstance.delegate = self;
    luaInstance.instanceHandlersManager.errorHandler = self;
    [luaInstance changeLuaBundleWithPath:bundlePath];
    [luaInstance changeRootView:self.benchLuaContentView];
    return luaInstance;
}

#pragma mark - MLNHotReloadPresenterDelegate
- (int)currentPortHotReloadPresenter:(nonnull MLNHotReloadPresenter *)hotReloadPresenter
{
    return self.serverManager.currentUSBPort;
}

- (void)hotReloadPresenter:(nonnull MLNHotReloadPresenter *)hotReloadPresenter QRCodeOnError:(nonnull NSError *)error
{
    [self.presenter tip:error.localizedDescription duration:0.3 delay:1];
}

- (void)hotReloadPresenter:(nonnull MLNHotReloadPresenter *)hotReloadPresenter changePort:(int)port
{
    [self.serverManager restartUSBWithPort:port];
}

- (void)hotReloadPresenter:(nonnull MLNHotReloadPresenter *)hotReloadPresenter hiddenNavBar:(BOOL)hidden {
    [self.viewController.navigationController setNavigationBarHidden:hidden];
}

- (void)hotReloadPresenter:(nonnull MLNHotReloadPresenter *)hotReloadPresenter readDataFromQRCode:(nonnull NSString *)ip port:(int)port
{
    [self.serverManager startNetWithIP:ip port:port];
}

#pragma mark - MLNServerHandlerDelegate
- (void)reload:(NSString * )bundlePath entryFilePath:(NSString * _Nonnull)entryFilePath params:(NSDictionary * _Nonnull )params
{
    if (!_running || !stringNotEmpty(bundlePath)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.benchLuaInstance = [self createLuaInstance:bundlePath entryFilePath:entryFilePath params:params];
        // 参数
        NSMutableDictionary *extraInfo = nil;
        if (self.extraInfoCallback) {
            NSDictionary *tmp =  self.extraInfoCallback();
            if (tmp) {
                extraInfo = [NSMutableDictionary dictionaryWithDictionary:tmp];
            } else {
                extraInfo = [NSMutableDictionary dictionary];
            }
            if (params) {
                [extraInfo setValuesForKeysWithDictionary:params];
            }
        }
        //TODO: - 设置Lua源
        NSString *relativePath = [bundlePath stringByReplacingOccurrencesOfString:[self hotReloadBundlePath] withString:@""];
        relativePath = [relativePath stringByAppendingPathComponent:entryFilePath];
        NSString *resouce = [kLuaHotReloadHost stringByAppendingString:relativePath];
        [extraInfo mln_setObject:resouce forKey:@"LuaSource"];
        // 更新bundlePath
        [self.benchLuaInstance runWithEntryFile:entryFilePath windowExtra:extraInfo error:NULL];
    });
}

- (void)startToGenerateCodeCoverageReportFile {
    lua_State *L = self.luaInstance.luaCore.state;
    if (L) {
        lua_getglobal(L, "gencoveragereport");
        if (lua_isfunction(L, -1)) {
            lua_pcall(L, 0, 0, 0);
        } else {
            [self print:@"请先开启覆盖率统计，然后跑一遍项目，才可以生成统计报告"];
        }
    } else {
        [self print:@"请先跑一遍项目，再点击生成报告按钮"];
    }
}

#pragma mark - MLNServerListenerProtocol
- (void)server:(MLNServer *)server beginCheckUSBReachable:(int)port
{
    [self.presenter show:@"正在检查USB连通性..." duration:0.3];
}

- (void)server:(MLNServer *)server endCheckUSBReachable:(int)port isReachable:(BOOL)isReachable
{
    NSString *msg = isReachable ? @"USB正常" : @"重启USB...";
    [self.presenter hidden:msg duration:0.3 delay:1];
}

- (void)server:(MLNServer *)server onConnected:(NSString *)ip port:(int)port
{
    [self.presenter tip:@"连接成功" duration:0.3 delay:1.f];
}

- (void)server:(MLNServer *)server onDisconnected:(NSString *)ip port:(int)port error:(NSError *)error
{
    [self.presenter tip:@"连接断开" duration:0.3 delay:1.f];
}

#pragma mark - MLNLogDelegate
- (BOOL)canHandleAssert:(MLNKitInstance *)instance
{
    return YES;
}

- (void)instance:(MLNKitInstance *)instance error:(NSString *)error
{
    [self.serverManager error:error];
}

- (void)instance:(MLNKitInstance *)instance luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback
{
    [self.serverManager error:error];
}

#pragma mark - MLNDebugPrintObserver
- (void)print:(NSString *)msg
{
    [self.serverManager log:msg];
}

#pragma mark - MLNKitInstanceDelegate
- (void)didSetupLuaCore:(MLNKitInstance *)luaInstance
{
    // 注册print
    [luaInstance registerClasses:@[[MLNDebugPrintFunction class],
                                   [MLNDebugCodeCoverageFunction class]] error:NULL];
    // 注册外部bridge
    if (self.registerBridgeClassesCallback) {
        self.registerBridgeClassesCallback(luaInstance);
    }
    if (self.setupInstanceCallback) {
        self.setupInstanceCallback(luaInstance);
    }
}

- (void)instance:(MLNKitInstance *)instance didFinishRun:(NSString *)entryFileName
{
    if (instance == self.benchLuaInstance) {
        [self.rootView lua_removeAllSubViews];
        [self.rootView addSubview:self.benchLuaContentView];
        // 切换View
        UIView *tmpView = self.luaContentView;
        self.luaContentView = self.benchLuaContentView;
        self.benchLuaContentView = tmpView;
        [self.benchLuaContentView lua_removeAllSubViews];
        // 切换Instance
        self.luaInstance = self.benchLuaInstance;
        if (self.updateCallback) {
            self.updateCallback(self.luaInstance);
        }
        self.benchLuaInstance = nil;
        [self.luaInstance doLuaWindowDidAppear];
        [self.presenter tip:@"内容已刷新" duration:0.3 delay:1];
    }
}

#pragma mark - Getter
- (MLNServer *)server
{
    return [MLNServer getInstance];
}

- (NSString *)entryFilePath
{
    return self.serverManager.entryFilePath;
}

- (NSString *)relativeEntryFilePath
{
    return self.serverManager.relativeEntryFilePath;
}

- (NSString *)luaBundlePath
{
    return self.serverManager.luaBundlePath;
}

- (NSString *)hotReloadBundlePath
{
    return self.serverManager.hotReloadBundlePath;
}

- (BOOL)isUtilViewControllerShow
{
    return _presenter.isUtilViewControllerShow;
}

@end
