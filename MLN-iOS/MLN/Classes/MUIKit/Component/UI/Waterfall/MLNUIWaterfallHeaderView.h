//
//  MLNUIWaterfallHeaderView.h
//
//
//  Created by MoMo on 2019/5/10.
//

#import <UIKit/UIKit.h>
#import "MLNUIReuseContentView.h"

NS_ASSUME_NONNULL_BEGIN

#define kMLNUIWaterfallHeaderViewReuseID @"kMLNUIWaterfallHeaderViewReuseID"

@class MLNUIWaterfallHeaderView, MLNUIReuseContentView;
@protocol MLNUIWaterfallHeaderViewDelegate <NSObject>

@optional
/// headerView 上的内容大小发生变更时回调
- (void)mlnuiWaterfallViewHeaderViewShouldReload:(MLNUIWaterfallHeaderView *)headerView size:(CGSize)size;

/// 获取自适应 headerView 大小
- (CGSize)mlnuiWaterfallAutoFitSizeForHeaderView:(MLNUIWaterfallHeaderView *)headerView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLNUIWaterfallHeaderView : UICollectionReusableView <MLNUIReuseCellProtocol>

@property (nonatomic, strong, readonly) Class reuseContentViewClass;
@property (nonatomic, weak) id<MLNUIWaterfallHeaderViewDelegate> delegate;

@end

@interface MLNUIWaterfallAutoFitHeaderView : MLNUIWaterfallHeaderView

@end

NS_ASSUME_NONNULL_END
