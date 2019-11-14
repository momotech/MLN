//
//  MLNSimpleViewPagerCell.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNHomeTableView;
@interface MLNSimpleViewPagerCell : UICollectionViewCell

@property (nonatomic, copy) NSString *tableType;
@property (nonatomic, strong, readonly) UITableView *mainTableView;

- (void)requestData:(BOOL)firstRequest;

@end

NS_ASSUME_NONNULL_END
