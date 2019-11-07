//
//  MLNSimpleViewPagerCell.h
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
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
