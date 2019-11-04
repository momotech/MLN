//
//  MLNCanvasAnimation.h
//  MLN
//
//  Created by MoMo on 2019/5/13.
//

#import <Foundation/Foundation.h>
#import "MLNAnimationConst.h"
#import "MLNEntityExportProtocol.h"

typedef NS_ENUM(NSUInteger,MLNCanvasAnimationStatus){
    MLNCanvasAnimationStatusNone = 0,
    MLNCanvasAnimationStatusRunning,
    MLNCanvasAnimationStatusPause,
    MLNCanvasAnimationStatusReadyToPlay,
    MLNCanvasAnimationStatusReadyToResume,
    MLNCanvasAnimationStatusStop,
};

NS_ASSUME_NONNULL_BEGIN

@class MLNBlock;
@interface MLNCanvasAnimation : NSObject <NSCopying, MLNEntityExportProtocol>

@property (nonatomic, strong, readonly) CAAnimationGroup *animationGroup;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CABasicAnimation *> *animations;
@property (nonatomic, assign) MLNAnimationValueType pivotXType;
@property (nonatomic, assign) CGFloat pivotX;
@property (nonatomic, assign) MLNAnimationValueType pivotYType;
@property (nonatomic, assign) CGFloat pivotY;
@property (nonatomic, assign) BOOL autoBack;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic, assign) MLNAnimationInterpolatorType interpolator;
@property (nonatomic, assign) MLNAnimationRepeatType repeatType;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSInteger executeCount;
@property (nonatomic, assign) MLNCanvasAnimationStatus status;

//Usually overridden in subclasses
@property (nonatomic, copy) NSString *animationKey;
- (CABasicAnimation *)animationForKey:(NSString *)key;
- (NSArray <CABasicAnimation *>*)animationValues;
- (void)startWithView:(UIView *)targetView;
- (void)cancel;
- (void)setStartCallback:(MLNBlock *)callback;
- (void)setEndCallback:(MLNBlock *)callback;
- (void)setRepeatCallback:(MLNBlock *)callback;
- (void)tick;
- (void)animationRealStart;


@end

NS_ASSUME_NONNULL_END
