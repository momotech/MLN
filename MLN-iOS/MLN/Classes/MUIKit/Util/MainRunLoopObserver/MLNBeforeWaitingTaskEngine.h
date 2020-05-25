//
//  MLNBeforeWaitingTaskEngine.h
//  MMLNua
//
//  Created by MoMo on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MLNKitInstance;
@protocol MLNBeforeWaitingTaskProtocol;
@interface MLNBeforeWaitingTaskEngine : NSObject

@property (nonatomic, weak, readonly) MLNKitInstance *luaInstance;

- (instancetype)initWithLuaInstance:(MLNKitInstance *)luaInstance order:(CFIndex)order;

- (void)start;
- (void)end;

- (void)pushTask:(id<MLNBeforeWaitingTaskProtocol>)task;
- (void)popTask:(id<MLNBeforeWaitingTaskProtocol>)task;
- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
