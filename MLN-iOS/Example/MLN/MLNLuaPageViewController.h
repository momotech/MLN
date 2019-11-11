//
//  MLNLuaPageViewController.h
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import <MLNKitViewController.h>
#import "MLNActionProtocol.h"

@class MLNPackage;

NS_ASSUME_NONNULL_BEGIN

@interface MLNLuaPageViewController : MLNKitViewController<MLNActionProtocol>

//根据该package进行包内容检查加载
@property (nonatomic, strong) MLNPackage *package;

- (instancetype)initWithURLString:(NSString *)urlString;
- (instancetype)initWithActionItem:(MLNActionItem *)actionItem;

@end

NS_ASSUME_NONNULL_END
