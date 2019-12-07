//
//  MLNActionManager.h
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNAnimationConst.h"
#import "MLNActionDefine.h"

@class MLNActionItem;

NS_ASSUME_NONNULL_BEGIN

@interface MLNActionManager : NSObject

+ (instancetype)actionManager;

- (void)handlerGotoWithActionItem:(MLNActionItem *)actionItem;

@end

NS_ASSUME_NONNULL_END
