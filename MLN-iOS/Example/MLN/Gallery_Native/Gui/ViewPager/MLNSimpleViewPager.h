//
//  MLNSimpleViewPager.h
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNHomeTableView.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNSimpleViewPager;
@class MLNTabSegmentView;
@protocol MLNCycleScrollViewDelegate <NSObject>

@property (nonatomic, assign) NSInteger cellCounts;
@property (nonatomic, weak) MLNSimpleViewPager *viewPager;
@property (nonatomic, weak) UICollectionView *targetCollectionView;

@end


@interface MLNSimpleViewPager : UIView<MLNCycleScrollViewDelegate>

- (void)reloadWithDataList:(NSArray *)dataList;
- (void)scrollToPage:(NSUInteger)index aniamted:(BOOL)animated;
- (void)setRefreshBlock:(RefreshBlock)refreshBlock;
- (void)setLoadingBlock:(LoadingBlock)loadingBlock;
- (void)setSearchBlock:(SearchBlock)searchBlock;

@end

NS_ASSUME_NONNULL_END
