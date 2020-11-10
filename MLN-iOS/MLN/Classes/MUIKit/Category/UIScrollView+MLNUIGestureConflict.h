//
//  UIScrollView+MLNUIGestureConflict.h
//  ArgoUI
//
//  Created by MOMO on 2020/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (MLNUIGestureConflict)

+ (void)argoui_installScrollViewPanGestureConflictHandler;
- (BOOL)argoui_isVerticalDirection;

@end

NS_ASSUME_NONNULL_END
