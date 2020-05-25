//
//  MLNUIBeforeWaitingTaskEngine.h
//  MMLNUIua
//
//  Created by MoMo on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MLNUIKitInstance;
@protocol MLNUIBeforeWaitingTaskProtocol;
@interface MLNUIBeforeWaitingTaskEngine : NSObject

@property (nonatomic, weak, readonly) MLNUIKitInstance *luaInstance;

- (instancetype)initWithLuaInstance:(MLNUIKitInstance *)luaInstance order:(CFIndex)order;

- (void)start;
- (void)end;

- (void)pushTask:(id<MLNUIBeforeWaitingTaskProtocol>)task;
- (void)popTask:(id<MLNUIBeforeWaitingTaskProtocol>)task;
- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
