//
//  MLNUIInternalWaterfallView.h
//
//
//  Created by MoMo on 2019/6/18.
//

#import "MLNUIInnerCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIInternalWaterfallView : MLNUIInnerCollectionView

- (void)setHeaderView:(UIView *)headerView;
- (void)resetHeaderView;

+ (UIView *)headerViewInWaterfall:(UICollectionView *)collectionView;

@end

NS_ASSUME_NONNULL_END
