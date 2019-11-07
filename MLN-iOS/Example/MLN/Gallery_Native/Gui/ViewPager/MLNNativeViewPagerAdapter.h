//
//  MLNNativeViewPagerAdapter.h
//  MLN
//
//  Created by MoMo on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "MLNNativeViewPager.h"

@interface MLNNativeViewPagerAdapter : NSObject <UICollectionViewDataSource, MLNNativeCycleScrollViewDelegate>

@property (nonatomic, weak) MLNNativeViewPager *viewPager;
@property (nonatomic, assign) NSInteger cellCounts;
@property (nonatomic, weak) UICollectionView *targetCollectionView;

@end
