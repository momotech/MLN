//
//  MLNUICanvasAnimation.h
//  MLNUI
//
//  Created by MoMo on 2019/5/13.
//

#import <Foundation/Foundation.h>
#import "MLNUIAnimationConst.h"
#import "MLNUIEntityExportProtocol.h"

typedef NS_ENUM(NSUInteger,MLNUICanvasAnimationStatus){
    MLNUICanvasAnimationStatusNone = 0,
    MLNUICanvasAnimationStatusRunning,
    MLNUICanvasAnimationStatusPause,
    MLNUICanvasAnimationStatusReadyToPlay,
    MLNUICanvasAnimationStatusReadyToResume,
    MLNUICanvasAnimationStatusStop,
};

NS_ASSUME_NONNULL_BEGIN

@class MLNUIBlock;
@interface MLNUICanvasAnimation : NSObject <NSCopying, MLNUIEntityExportProtocol>

@property (nonatomic, strong, readonly) CAAnimationGroup *animationGroup;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CABasicAnimation *> *animations;
@property (nonatomic, assign) MLNUIAnimationValueType pivotXType;
@property (nonatomic, assign) CGFloat pivotX;
@property (nonatomic, assign) MLNUIAnimationValueType pivotYType;
@property (nonatomic, assign) CGFloat pivotY;
@property (nonatomic, assign) BOOL autoBack;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic, assign) MLNUIAnimationInterpolatorType interpolator;
@property (nonatomic, assign) MLNUIAnimationRepeatType repeatType;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSInteger executeCount;
@property (nonatomic, assign) MLNUICanvasAnimationStatus status;

//Usually overridden in subclasses
@property (nonatomic, copy) NSString *animationKey;
- (CABasicAnimation *)animationForKey:(NSString *)key;
- (NSArray <CABasicAnimation *>*)animationValues;
- (void)startWithView:(UIView *)targetView;
- (void)cancel;
- (void)setStartCallback:(MLNUIBlock *)callback;
- (void)setEndCallback:(MLNUIBlock *)callback;
- (void)setRepeatCallback:(MLNUIBlock *)callback;
- (void)tick;
- (void)animationRealStart;


@end

NS_ASSUME_NONNULL_END
