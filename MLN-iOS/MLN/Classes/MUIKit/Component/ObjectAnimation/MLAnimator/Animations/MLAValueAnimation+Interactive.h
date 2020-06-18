//
//  MLAValueAnimation+Interactive.h
//  ArgoUI
//
//  Created by Dai Dongpeng on 2020/6/18.
//

#import "MLAAnimation.h"
#import "MLNUIInteractiveBehavior.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLAValueAnimation ()
@property (nonatomic, strong) id obscureFrom;
@property (nonatomic, strong) NSMutableArray <MLNUIInteractiveBehavior *> *behaviors;
@end

@interface MLAValueAnimation (Interactive)
- (void)updateWithFactor:(CGFloat)factor;
- (void)addInteractiveBehavior:(MLNUIInteractiveBehavior *)behavior;
@end

NS_ASSUME_NONNULL_END
