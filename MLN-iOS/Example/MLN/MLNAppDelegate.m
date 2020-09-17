//
//  MLNAppDelegate.m
//  MLN
//
//  Created by MoMo on 08/02/2019.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNAppDelegate.h"
#import "MLNGalleryNative.h"
#import <objc/runtime.h>
#import <UIImageView+WebCache.h>
#import <UIImageView+AFNetworking.h>
#import "MLNGalleryMainViewController.h"
#import <MLN/MLNFile.h>
#import <MLN/MLNKitEnvironment.h>

#import "MLNMyHttpHandler.h"
#import "MLNMyRefreshHandler.h"
#import "MLNMyImageHandler.h"
#import "MLNNavigatorHandler.h"
#import <MLNLink.h>
#import "MLNUIKVOObserver.h"
#import "MLNUIKit.h"
#import "MLNUIMyImageHandler.h"
#import "FLEXManager.h"
#import "MLNUIFPSStatus.h"
#import "MLNUILogViewer.h"
#import "MLNUILoadTimeStatistics.h"
#import "MLNUIHeader.h"
#import "MLNUIMyErrorHandler.h"

@interface MLNAppDelegate ()

@property (nonatomic, strong) id<MLNHttpHandlerProtocol> httpHandler;
@property (nonatomic, strong) id<MLNRefreshDelegate> refreshHandler;
@property (nonatomic, strong) id<MLNImageLoaderProtocol> imgLoader;
@property (nonatomic, strong) id<MLNNavigatorHandlerProtocol> navHandler;
@property (nonatomic, strong) id<MLNUIErrorHandlerProtocol> errorHandler;

@property (nonatomic, strong) id<MLNUIImageLoaderProtocol> imgLoader2;
@end

@implementation MLNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MLNUIFPSStatus sharedInstance] open];
//    [[FLEXManager sharedManager] showExplorer];
//    [MLNUILogViewer setup];
    [self setupMLNKitEnvironment];
    // 根据标志位判断是否禁用图片加载功能
    if (kDisableImageLoad) {
        method_exchangeImplementations(class_getInstanceMethod([UIImageView class], @selector(sd_setImageWithURL:)), class_getInstanceMethod([self class], @selector(sd_setImageWithURL:)));
        method_exchangeImplementations(class_getInstanceMethod([UIImageView class], @selector(sd_setImageWithURL:placeholderImage:)), class_getInstanceMethod([self class], @selector(sd_setImageWithURL:placeholderImage:)));
    }
    
    // copy 主bundle中文件到沙盒中
    [self copyJsonFilesToSandbox];
    
    [self registerLink];

    return YES;
}

- (void)setupMLNKitEnvironment
{
    // 初始化handlers
    self.httpHandler = [[MLNMyHttpHandler alloc] init];
    self.refreshHandler = [[MLNMyRefreshHandler alloc] init];
    self.imgLoader = [[MLNMyImageHandler alloc] init];
    self.navHandler = [[MLNNavigatorHandler alloc] init];
    // MLNUIKit
    self.imgLoader2 = [[MLNUIMyImageHandler alloc] init];
    self.errorHandler = [MLNUIMyErrorHandler new];
    
    [MLNKitEnvironment instancePreload];
    [MLNKitEnvironment setDefaultHttpHandler:self.httpHandler];
    [MLNKitEnvironment setDefaultScrollRefreshHandler:self.refreshHandler];
    [MLNKitEnvironment setDefaultImageLoader:self.imgLoader];
    [MLNKitEnvironment setDefaultNavigatorHandler:self.navHandler];
    
    [MLNLink registerName:@"MLNLuaGallery" linkClassName:@"MLNLuaGalleryViewController"];
    [self setupMLNUIKitEnvironment];
}

- (void)setupMLNUIKitEnvironment
{
    [MLNUIKitEnvironment instancePreload];
    [MLNUIKitEnvironment setDefaultHttpHandler:self.httpHandler];
    [MLNUIKitEnvironment setDefaultScrollRefreshHandler:self.refreshHandler];
    [MLNUIKitEnvironment setDefaultImageLoader:self.imgLoader2];
    [MLNUIKitEnvironment setDefaultNavigatorHandler:self.navHandler];
    [MLNUIKitEnvironment setDefaultErrorHandler:self.errorHandler];
#if DEBUG && 0
    [MLNUIKitEnvironment setPerformanceMonitor: [MLNUILoadTimeStatistics sharedStatistics]];
    MLNUIKitPerformanceMonitorForDebug = [MLNUILoadTimeStatistics sharedStatistics];
#endif
    [MLNUILink registerName:@"MLNLuaGallery" linkClassName:@"MLNLuaGalleryViewController"];
}

- (void)copyJsonFilesToSandbox
{
    NSString *jsonDirectoryPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/gallery.bundle/json"];
    NSError *error = nil;
    NSArray *jsonFilePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:jsonDirectoryPath error:&error];
    NSString *destFileDirectory = [[MLNFile fileManagerRootPath] stringByAppendingPathComponent:@"gallery.bundle/json"];
    BOOL isDir = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:destFileDirectory isDirectory:&isDir];
    if (!exist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:destFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        for (NSString *filePath in jsonFilePaths) {
            NSString *oldFilePath = [jsonDirectoryPath stringByAppendingPathComponent:filePath];
            NSError *error = nil;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:&error];
            if (!success) {
                NSLog(@"-----> error:%@", error);
            }
        }
    }
    for (NSString *filePath in jsonFilePaths) {
        NSString *srcFilePath = [jsonDirectoryPath stringByAppendingPathComponent:filePath];
        NSString *dstFilePath = [destFileDirectory stringByAppendingPathComponent:filePath];
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:srcFilePath toPath:dstFilePath error:NULL];
        if (success) {
            NSLog(@"------> %@", dstFilePath);
        }
    }
}


- (void)sd_setImageWithURL:(NSURL *)url
{
    // @note: 测试内存占用时候去掉图片
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder
{
    // @note: 测试内存占用时候去掉图片
}

- (void)registerLink {
    [MLNUILink registerName:@"CustomHotReload" linkClassName:@"MLNUICustomHotReloadViewController"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
