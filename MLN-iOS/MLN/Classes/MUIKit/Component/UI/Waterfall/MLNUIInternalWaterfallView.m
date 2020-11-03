//
//  MLNUIInternalWaterfallView.m
//
//
//  Created by MoMo on 2019/6/18.
//

#import "MLNUIInternalWaterfallView.h"
#import "UIScrollView+MLNUIGestureConflict.h"

@interface MLNUIInternalWaterfallView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong, nullable) UIView *headerView; //瀑布流header 老接口需要用到此属性

@end

@implementation MLNUIInternalWaterfallView

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
    if ([collectionView isKindOfClass:[MLNUIInternalWaterfallView class]]) {
        MLNUIInternalWaterfallView *waterfallView =  (MLNUIInternalWaterfallView *)collectionView;
        return waterfallView.headerView;
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:self.panGestureRecognizer.class] &&
        [otherGestureRecognizer isKindOfClass:self.panGestureRecognizer.class]) {
        return YES;
    }
    return NO;
}

@end
