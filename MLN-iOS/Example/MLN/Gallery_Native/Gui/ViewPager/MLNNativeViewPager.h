//
//  MLNNativeViewPager.h
//  MLN
//
//  Created by MoMo on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "MLNTabSegmentViewDelegate.h"

@class MLNNativeViewPager;
@class MLNNativeTabSegmentView;
@protocol MLNNativeCycleScrollViewDelegate <NSObject>

@property (nonatomic, assign) NSInteger cellCounts;
@property (nonatomic, weak) MLNNativeViewPager *viewPager;
@property (nonatomic, weak) UICollectionView *targetCollectionView;

@end

@interface MLNNativeViewPager : UIView <MLNTabSegmentViewDelegate>

@property (nonatomic, weak) id<UICollectionViewDataSource, MLNNativeCycleScrollViewDelegate> adapter;
@property (nonatomic, weak) id<UIScrollViewDelegate> segmentViewHandler;
@property (nonatomic, weak) MLNNativeTabSegmentView *tabSegmentView;
@property (nonatomic, assign) NSInteger totalItemsCount;
/** 目标索引 **/
@property (nonatomic, assign) NSInteger missionIndex;
@property (nonatomic, assign) BOOL missionAnimated;
@property (nonatomic, assign) UIEdgeInsets padding;
/** 是否开启预加载 **/
@property (nonatomic, assign) BOOL aheadLoad;
/** scroll to page **/
- (void)scrollToPage:(NSUInteger)index aniamted:(BOOL)animated;

- (NSInteger)updateTotalItemCount:(NSInteger)cellCount;

- (void)setRecurrence:(BOOL)recurrence;

@end
