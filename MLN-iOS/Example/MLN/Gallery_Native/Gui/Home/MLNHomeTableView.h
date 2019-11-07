//
//  MLNHomeTableView.h
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^RefreshBlock)(UITableView *);
typedef void(^LoadingBlock)(UITableView *);
typedef void(^SearchBlock)(void);

@interface MLNHomeTableView : UIView

@property (nonatomic, copy) NSString *tableType;

- (void)setRefreshBlock:(RefreshBlock)refreshBlock;
- (void)setLoadingBlock:(LoadingBlock)loadingBlock;
- (void)setSearchBlock:(SearchBlock)searchBlock;

- (void)reloadTableWithDataList:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
