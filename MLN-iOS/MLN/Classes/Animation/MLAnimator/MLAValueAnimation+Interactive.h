//
//  MLAValueAnimation+Interactive.h
//  ArgoUI
//
//  Created by MOMO on 2020/6/18.
//

#import "MLAAnimation.h"
#import "MLAInteractiveBehaviorProtocol.h"

//@class MLNUIInteractiveBehavior;
NS_ASSUME_NONNULL_BEGIN

@interface MLAValueAnimation ()
@property (nonatomic, strong, nullable) id obscureFrom;
@property (nonatomic, strong) NSMutableArray <id<MLAInteractiveBehaviorProtocol>> *behaviors;
@end

@interface MLAValueAnimation (Interactive)

/**
 * @param factor 比例因子，取值范围 [0, 1]
 * @discussion 根据贝塞尔曲线公式计算factor对应的y值
 */
- (void)updateWithFactor:(CGFloat)factor isBegan:(BOOL)isBegan;

/**
 * @param behavior 交互行为
 * @discussion 向动画中添加一个交互行为
 */
- (void)addInteractiveBehavior:(id<MLAInteractiveBehaviorProtocol>)behavior;

/**
 * @param behavior 交互行为
 * @discussion 从动画中移除一个交互行为
*/
- (void)removeInteractiveBehavior:(id<MLAInteractiveBehaviorProtocol>)behavior;

@end

NS_ASSUME_NONNULL_END
