//
//  MLNSimpleViewPagerCell.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNHomeTableView.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNHomeTableView;
@interface MLNSimpleViewPagerCell : UICollectionViewCell

@property (nonatomic, strong, readonly) MLNHomeTableView *mainTableView;

- (void)setRefreshBlock:(RefreshBlock)refreshBlock;
- (void)setLoadingBlock:(LoadingBlock)loadingBlock;
- (void)setSearchBlock:(SearchBlock)searchBlock;

@end

NS_ASSUME_NONNULL_END
