//
//  MLNApplication.m
//  
//
//  Created by MoMo on 2019/2/26.
//

#import "MLNApplication.h"
#import "MLNKitHeader.h"
#import "MLNKitInstance.h"
#import "MLNStaticExporterMacro.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNBlock.h"

@interface MLNApplication()

@property (nonatomic, strong) NSMutableArray<MLNBlock *> *enterForegroundCallbacks;
@property (nonatomic, strong) NSMutableArray<MLNBlock *> *enterBackgroundCallbacks;

@end

@implementation MLNApplication

+ (void)mln_addEnterForegroundCallback:(MLNBlock *)callback
{
    if (!callback) {
        return;
    }
    MLNApplication *application = MLN_KIT_INSTANCE(self.mln_currentLuaCore).instanceHandlersManager.application;
    [application addEnterForegroundCallback:callback];
}

+ (void)mln_addEnterBackgroundCallback:(MLNBlock *)callback
{
    if (!callback) {
        return;
    }
    MLNApplication *application = MLN_KIT_INSTANCE(self.mln_currentLuaCore).instanceHandlersManager.application;
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

- (void)addEnterForegroundCallback:(MLNBlock *)callback
{
    if (!self.enterForegroundCallbacks) {
        self.enterForegroundCallbacks = [NSMutableArray array];
    }
    [self.enterForegroundCallbacks addObject:callback];
}

- (void)addEnterBackgroundCallback:(MLNBlock *)callback
{
    if (!self.enterBackgroundCallbacks) {
        self.enterBackgroundCallbacks = [NSMutableArray array];
    }
    [self.enterBackgroundCallbacks addObject:callback];
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNApplication)
LUA_EXPORT_STATIC_METHOD(setForeground2BackgroundCallback, "mln_addEnterBackgroundCallback:", MLNApplication)
LUA_EXPORT_STATIC_METHOD(setBackground2ForegroundCallback, "mln_addEnterForegroundCallback:", MLNApplication)
LUA_EXPORT_STATIC_END(MLNApplication, Application, NO, NULL)

@end
