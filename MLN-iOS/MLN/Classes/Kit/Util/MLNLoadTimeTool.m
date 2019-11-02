//
//  MLNLoadTimeTool.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/2.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNLoadTimeTool.h"

@implementation MLNLoadTimeTool
{
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
    NSTimeInterval _luaCoreCreateStartTime;
    NSTimeInterval _luaCoreCreateEndTime;
    NSTimeInterval _loadScriptStartTime;
    NSTimeInterval _loadScriptEndTime;
}

- (void)resetAllTimeRecord
{
    _startTime = 0.0;
    _endTime = 0.0;
    _luaCoreCreateStartTime = 0.0;
    _luaCoreCreateEndTime = 0.0;
    _loadScriptStartTime = 0.0;
    _loadScriptEndTime = 0.0;
}

- (void)recordStartTime
{
    [self resetAllTimeRecord];
    _startTime = [NSDate date].timeIntervalSince1970;
}

- (void)recordEndTime
{
    _endTime = [NSDate date].timeIntervalSince1970;
}

- (NSTimeInterval)allLoadTime
{
    return _endTime - _startTime;
}


- (void)resetLuaCoreCreateTime
{
    _luaCoreCreateStartTime =
}

- (void)recordCreateLuaCoreStartTime
{
    
}

- (void)recordCreateLuaCoreEndTime
{
    
}

- (NSTimeInterval)luaCoreCreateTime
{
    
}

- (void)resetLuaScriptLoadTime
{
    
}

- (void)recordLoadScriptStartTime
{
    
}

- (void)recordLoadScriptEndTime
{
    
}

- (NSTimeInterval)loadScriptTime
{
    
}

@end
