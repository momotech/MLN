//
//  MLNActionItem.m
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import "MLNActionItem.h"
#import <NSString+MLNKit.h>
#import "MLNActionDefine.h"

@interface MLNActionItem()
{
    NSDictionary *_params;
}

@end

@implementation MLNActionItem

- (instancetype)initWithAction:(nonnull NSString *)action
{
    self = [self initWithAction:action params:nil];
    return self;
}

- (instancetype)initWithAction:(nonnull NSString *)action params:(nullable NSDictionary *)params
{
    if (self = [super init]) {
        _action = action;
        _params = params;
        [self interpretationAction];
    }
    return self;
}

//初次解析action
- (void)interpretationAction
{
    if (![_action isKindOfClass:[NSString class]] ) {
        return;
    }
    NSMutableDictionary *mergeDictM = [NSMutableDictionary dictionary];
    _actionInfo = mergeDictM;
    //合并拓展参数
    if ([_params isKindOfClass:[NSDictionary class]]) {
        [mergeDictM addEntriesFromDictionary:_params];
    }
    if (![_action hasPrefix:@"{"]) {
        return;
    }
    NSMutableDictionary *actionDict = [NSJSONSerialization JSONObjectWithData:[_action dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if (actionDict == nil || ![actionDict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _actionType = [actionDict objectForKey:@"actionType"];
    NSString *prm = [actionDict objectForKey:@"prm"];
    //取出参数字段，解析为字典
    if (![prm isKindOfClass:[NSString class]] || ![prm hasPrefix:@"{"]) {
        return;
    }
    NSDictionary *prmDict = [NSJSONSerialization JSONObjectWithData:[prm dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if ([prmDict isKindOfClass:[NSDictionary class]]) {
        [mergeDictM addEntriesFromDictionary:prmDict];
    }
}

@end
