//
//  MLNLoadTimeTool.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/2.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNLoadTimeTool : NSObject

- (void)resetAllTimeRecord;
- (void)recordStartTime;
- (void)recordEndTime;
- (NSTimeInterval)allLoadTime;

- (void)resetLuaCoreCreateTime;
- (void)recordCreateLuaCoreStartTime;
- (void)recordCreateLuaCoreEndTime;
- (NSTimeInterval)luaCoreCreateTime;

- (void)resetLuaScriptLoadTime;
- (void)recordLoadScriptStartTime;
- (void)recordLoadScriptEndTime;
- (NSTimeInterval)loadScriptTime;

@end

NS_ASSUME_NONNULL_END
