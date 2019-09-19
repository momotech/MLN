//
//  MLNViewPager.h
//  MLN
//
//  Created by MoMo on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "MLNTabSegmentViewDelegate.h"
#import "MLNEntityExportProtocol.h"

@class MLNViewPager;
@class MLNTabSegmentView;
@protocol MLNCycleScrollViewDelegate <NSObject>

@property (nonatomic, assign) NSInteger cellCounts;
@property (nonatomic, weak) MLNViewPager *viewPager;

@end

@interface MLNViewPager : UIView <MLNEntityExportProtocol, MLNTabSegmentViewDelegate>

@property (nonatomic, weak) id<UICollectionViewDataSource,MLNCycleScrollViewDelegate> adapter;
@property (nonatomic, weak) id<UIScrollViewDelegate> segmentViewHandler;
@property (nonatomic, weak) MLNTabSegmentView *tabSegmentView;
@property (nonatomic, assign) NSInteger totalItemsCount;
/** 目标索引 **/
@property (nonatomic, assign) NSInteger missionIndex;
@property (nonatomic, assign) BOOL missionAnimated;
/** 是否开启预加载 **/
@property (nonatomic, assign) BOOL aheadLoad;
/** scroll to page **/
- (void)scrollToPage:(NSUInteger)index aniamted:(BOOL)animated;

- (NSInteger)updateTotalItemCount:(NSInteger)cellCount;

- (void)setRecurrence:(BOOL)recurrence;

@end
