//
//  MLAValueAnimation+Interactive.h
//  ArgoUI
//
//  Created by Dai Dongpeng on 2020/6/18.
//

#import "MLAAnimation.h"

@class MLNUIInteractiveBehavior;
NS_ASSUME_NONNULL_BEGIN

@interface MLAValueAnimation ()
@property (nonatomic, strong, nullable) id obscureFrom;
@property (nonatomic, strong) NSMutableArray <MLNUIInteractiveBehavior *> *behaviors;
@end

@interface MLAValueAnimation (Interactive)
- (void)updateWithFactor:(CGFloat)factor isBegan:(BOOL)isBegan;
- (void)addInteractiveBehavior:(MLNUIInteractiveBehavior *)behavior;
- (void)removeInteractiveBehavior:(MLNUIInteractiveBehavior *)behavior;

@end

NS_ASSUME_NONNULL_END
