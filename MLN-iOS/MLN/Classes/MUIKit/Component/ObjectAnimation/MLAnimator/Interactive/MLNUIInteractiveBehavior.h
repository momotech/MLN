//
//  MLNUIInteractiveBehavior.h
//  ArgoUI
//
//  Created by Dai Dongpeng on 2020/6/18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, InteractiveType) {
    InteractiveType_Gesture
};

typedef NS_ENUM(NSUInteger, InteractiveDirection) {
    InteractiveDirection_X,
    InteractiveDirection_Y
};

NS_ASSUME_NONNULL_BEGIN
@class MLAValueAnimation;

@interface MLNUIInteractiveBehavior : NSObject

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) InteractiveDirection direction;
@property (nonatomic, assign) float endDistance;
@property (nonatomic, assign) BOOL overBoundary;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL followEnable;

@property (nonatomic, strong) void(^startBlock)(void);
@property (nonatomic, strong) void(^finishBlock)(void);

@property (nonatomic, strong) void(^touchBlock)(float dx, float dy, float dis, float velocity);

- (instancetype)initWithType:(InteractiveType)type;

@property (nonatomic, weak) MLAValueAnimation *touchAnimation;
@end

NS_ASSUME_NONNULL_END
