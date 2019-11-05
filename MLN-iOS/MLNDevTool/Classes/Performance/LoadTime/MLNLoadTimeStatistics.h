//
//  MLNLoadTimeStatistics.h
//  MLN
//
//  Created by MoMo on 2019/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNLoadTimeStatistics : NSObject

- (void)resetAllTimeRecord;
- (void)recordStartTime;
- (void)recordEndTime;
- (NSTimeInterval)allLoadTime;

- (void)resetLuaCoreCreateTime;
- (void)recordLuaCoreCreateStartTime;
- (void)recordLuaCoreCreateEndTime;
- (NSTimeInterval)luaCoreCreateTime;

- (void)resetLuaScriptLoadTime;
- (void)recordLoadScriptStartTimeWithFileName:(NSString *)fileName;
- (void)recordLoadScriptEndTimeWithFileName:(NSString *)fileName;
- (NSTimeInterval)loadScriptTime;

@end

NS_ASSUME_NONNULL_END
