//
//  MLNLuaPageViewController.m
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import "MLNLuaPageViewController.h"
#import "MLNActionDefine.h"
#import "MLNActionItem.h"
#import "MLNAnimationConst.h"
#import "MLNControlContext.h"
#import "MLNPackage.h"
#import "MLNPackageManager.h"
#import <NSString+MLNKit.h>
#import <MLNLoadTimeStatistics.h>
#import <MLNKitInstance.h>

@interface MLNLuaPageViewController ()<MLNKitInstanceDelegate>

@end

@implementation MLNLuaPageViewController

#pragma mark - MLNActionProtocol
+ (void)mln_gotoWithActionItem:(MLNActionItem *)actionItem
{
    [self handleGotoActionWithItem:actionItem];
}

+ (void)handleGotoActionWithItem:(MLNActionItem *)actionItem
{
    NSInteger gotoValue = 0;
    BOOL animated = YES;
    if (actionItem.actionInfo != nil) {
        gotoValue = [[actionItem.actionInfo objectForKey:kMLNGotoTypeKey] integerValue];
        MLNAnimationAnimType animValue = [[actionItem.actionInfo objectForKey:kMLNAnimateTypeKey] integerValue];
        animated = (animValue != MLNAnimationAnimTypeNone);
    }
    NSString *urlString = [actionItem.actionInfo objectForKey:kMLNURLKey];
    if (urlString) {
        NSURL *URL = [NSURL URLWithString:urlString];
        if (URL) {
            NSDictionary *urlParams = [[URL query] mln_dictionaryFromQuery];
            if (urlParams) {
                NSMutableDictionary *mergeDictM = [NSMutableDictionary dictionaryWithDictionary:urlParams];
                [mergeDictM addEntriesFromDictionary:actionItem.actionInfo];
                actionItem.actionInfo = mergeDictM;
            }
        }
    }
    [[MLNLoadTimeStatistics sharedInstance] recordStartTime];
    UIViewController *topViewController = [MLNControlContext mln_topViewController];
    MLNLuaPageViewController *controller = [[MLNLuaPageViewController alloc] initWithActionItem:actionItem];
    controller.kitInstance.delegate = controller;
    switch (gotoValue) {
        case 0: {
            [topViewController.navigationController pushViewController:controller animated:animated];
        }
            break;
        case 1: {
            [topViewController.navigationController presentViewController:controller animated:animated completion:nil];
        }
            break;
        default:
            break;
    }
}

- (instancetype)initWithURLString:(NSString *)urlString
{
    MLNPackage *package = [[MLNPackage alloc] initWithURLString:urlString];
    if (self = [super initWithEntryFilePath:package.entryFile]) {
        [self changeCurrentBundlePath:package.bundlePath];
        self.package = package;
    }
    return self;
}

- (instancetype)initWithActionItem:(MLNActionItem *)actionItem
{
    //根据actionItem，解析出MLNPackage对象，计算出bundlePath，entryFile等信息
    MLNPackage *package = [[MLNPackage alloc] initWithActionItem:actionItem];
    if (self = [super initWithEntryFilePath:package.entryFile extraInfo:actionItem.actionInfo]) {
        [self changeCurrentBundlePath:package.bundlePath];
        self.package = package;
    }
   return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_package.needReload || _package.needDownload) {
        [self checkPackage];
    }
}

#pragma mark - MLNKitInstanceDelegate
- (void)instance:(MLNKitInstance *)instance didFinishRun:(NSString *)entryFileName
{
    [[MLNLoadTimeStatistics sharedInstance] recordEndTime];
    NSLog(@"------->布局完成：%@", @([[MLNLoadTimeStatistics sharedInstance] allLoadTime] * 1000));
}

- (void)checkPackage
{
    __weak typeof(self) weakSelf = self;
    [[MLNPackageManager sharedManager] loadPackage:self.package completion:^(BOOL success, MLNPackage *loadPackage, NSData *data, NSString *msg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success) {
            [strongSelf changeCurrentBundlePath:loadPackage.bundlePath];
            [strongSelf reloadWithEntryFilePath:loadPackage.entryFile];
        } else {
            NSLog(@"页面加载失败:%@ msg:%@",loadPackage.entryFile ,msg);
        }
    }];
}


@end
