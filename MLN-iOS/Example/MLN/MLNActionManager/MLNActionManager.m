//
//  MLNActionManager.m
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import "MLNActionManager.h"
#import <MLNKitViewController.h>
#import "MLNActionItem.h"
#import "MLNActionProtocol.h"
#import "MLNLuaPageViewController.h"
#import "MLNActionDefine.h"


@interface MLNActionManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, Class<MLNActionProtocol>> *actionsMap;

@end

@implementation MLNActionManager

+ (instancetype)actionManager
{
    static MLNActionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager setupActions];
    });
    return manager;
}

- (void)handlerGotoWithActionItem:(MLNActionItem *)actionItem
{
    if (actionItem.actionType.length > 0) {
        Class<MLNActionProtocol> actionClass = [self.actionsMap objectForKey:actionItem.actionType];
        if (actionClass != nil) {
            [actionClass performSelector:@selector(mln_gotoWithActionItem:) withObject:actionItem];
        }
    }
}

#pragma mark - getter
- (NSMutableDictionary<NSString *,Class<MLNActionProtocol>> *)actionsMap
{
    if (!_actionsMap) {
        _actionsMap = [NSMutableDictionary dictionary];
    }
    return _actionsMap;
}

- (void)setupActions
{
    // 注册Lua控制器
    [self.actionsMap setObject:MLNLuaPageViewController.class forKey:kLuaPageAction];
}

@end
