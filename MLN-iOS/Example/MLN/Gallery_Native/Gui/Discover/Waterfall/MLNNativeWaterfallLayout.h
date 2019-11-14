//
//  MLNNativeWaterfallLayout.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/7.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MLNNativeWaterfallLayoutDelegate;
@interface MLNNativeWaterfallLayout : UICollectionViewLayout

@property (nonatomic, assign) NSUInteger columnCount;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) UIEdgeInsets layoutInset;

@property (nonatomic, weak) id<MLNNativeWaterfallLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
