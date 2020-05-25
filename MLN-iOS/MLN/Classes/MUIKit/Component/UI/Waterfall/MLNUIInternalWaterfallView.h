//
//  MLNInternalWaterfallView.h
//
//
//  Created by MoMo on 2019/6/18.
//

#import "MLNInnerCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNInternalWaterfallView : MLNInnerCollectionView

- (void)setHeaderView:(UIView *)headerView;
- (void)resetHeaderView;

+ (UIView *)headerViewInWaterfall:(UICollectionView *)collectionView;

@end

NS_ASSUME_NONNULL_END
