//
//  MLNUIApplication.m
//  
//
//  Created by MoMo on 2019/2/26.
//

#import "MLNUIApplication.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitInstance.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIBlock.h"

@interface MLNUIApplication()

@property (nonatomic, strong) NSMutableArray<MLNUIBlock *> *enterForegroundCallbacks;
@property (nonatomic, strong) NSMutableArray<MLNUIBlock *> *enterBackgroundCallbacks;

@end

@implementation MLNUIApplication

+ (void)mlnui_addEnterForegroundCallback:(MLNUIBlock *)callback
{
    if (!callback) {
        return;
    }
    MLNUIApplication *application = MLNUI_KIT_INSTANCE(self.mlnui_currentLuaCore).instanceHandlersManager.application;
    [application addEnterForegroundCallback:callback];
}

+ (void)mlnui_addEnterBackgroundCallback:(MLNUIBlock *)callback
{
    if (!callback) {
        return;
    }
    MLNUIApplication *application = MLNUI_KIT_INSTANCE(self.mlnui_currentLuaCore).instanceHandlersManager.application;
    [application addEnterBackgroundCallback:callback];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willEnterForeground:(NSNotification *)notification
{
    [self.enterForegroundCallbacks makeObjectsPerformSelector:@selector(callIfCan)];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [self.enterBackgroundCallbacks makeObjectsPerformSelector:@selector(callIfCan)];
}

- (void)addEnterForegroundCallback:(MLNUIBlock *)callback
{
    if (!self.enterForegroundCallbacks) {
        self.enterForegroundCallbacks = [NSMutableArray array];
    }
    [self.enterForegroundCallbacks addObject:callback];
}

- (void)addEnterBackgroundCallback:(MLNUIBlock *)callback
{
    if (!self.enterBackgroundCallbacks) {
        self.enterBackgroundCallbacks = [NSMutableArray array];
    }
    [self.enterBackgroundCallbacks addObject:callback];
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUIApplication)
LUAUI_EXPORT_STATIC_METHOD(setForeground2BackgroundCallback, "mlnui_addEnterBackgroundCallback:", MLNUIApplication)
LUAUI_EXPORT_STATIC_METHOD(setBackground2ForegroundCallback, "mlnui_addEnterForegroundCallback:", MLNUIApplication)
LUAUI_EXPORT_STATIC_END(MLNUIApplication, Application, NO, NULL)

@end
