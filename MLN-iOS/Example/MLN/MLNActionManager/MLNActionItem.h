//
//  MLNActionItem.h
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNActionItem : NSObject

/**
 * 事件类型
 **/
@property (nonatomic, copy) NSString *actionType;

/**
 * 事件json
 **/
 @property (nonatomic, copy) NSString *action;
//格式化action，合并参数params以及action的prm数据
@property (nonatomic, strong) NSDictionary *actionInfo;

//action 可以为字符串，网络包地址，json字符串
/**
 {
 "a":"lua_page_action",
 "prm":"{"url":"http:\/\/www.test.com/base/cdn/alpha/recommend/index.lua"}"
 }
 **/
- (instancetype)initWithAction:(nonnull NSString *)action;
- (instancetype)initWithAction:(nonnull NSString *)action params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
