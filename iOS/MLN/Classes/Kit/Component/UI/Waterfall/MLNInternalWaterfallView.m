//
//  MLNInternalWaterfallView.m
//
//
//  Created by MoMo on 2019/6/18.
//

#import "MLNInternalWaterfallView.h"

@interface MLNInternalWaterfallView()

@property (nonatomic, strong, nullable) UIView *headerView; //瀑布流header 老接口需要用到此属性

@end

@implementation MLNInternalWaterfallView

- (void)setHeaderView:(UIView *)headerView
{
    _headerView = headerView;
}

- (void)resetHeaderView
{
    _headerView = nil;
}

+ (UIView *)headerViewInWaterfall:(UICollectionView *)collectionView
{
    if ([collectionView isKindOfClass:[MLNInternalWaterfallView class]]) {
        MLNInternalWaterfallView *waterfallView =  (MLNInternalWaterfallView *)collectionView;
        return waterfallView.headerView;
    }
    return nil;
}

@end
