//
//  MLNDiscoverAblbumDeatilHeaderView.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDiscoverAblbumDeatilHeaderView : UICollectionReusableView

@property (nonatomic, copy) dispatch_block_t selectBlock;

- (void)reloadWithData:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
