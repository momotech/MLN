//
//  MLNUIInnerCollectionView.m
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import "MLNUIInnerCollectionView.h"
#import "NSObject+MLNUICore.h"
#import "UIScrollView+MLNUIGestureConflict.h"

@interface MLNUIInnerCollectionView ()<UIGestureRecognizerDelegate>

@end

@implementation MLNUIInnerCollectionView

+ (void)load {
    [self argoui_installScrollViewPanGestureConflictHandler];
}

- (BOOL)mlnui_isConvertible
{
    return [self.containerView mlnui_isConvertible];
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.containerView.mlnui_luaCore;
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
