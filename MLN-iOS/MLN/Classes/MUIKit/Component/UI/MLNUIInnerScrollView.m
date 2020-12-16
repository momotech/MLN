//
//  MLNUIInnerScrollView.m
//  MLNUI
//
//  Created by MoMo on 2019/11/1.
//

#import "MLNUIInnerScrollView.h"
#import "MLNUIScrollViewDelegate.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "MLNUILuaCore.h"
#import "UIView+MLNUILayout.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIHStack.h"
#import "MLNUIVStack.h"
#import "UIScrollView+MLNUIGestureConflict.h"

@interface MLNUIInnerScrollViewContentStackNode : MLNUILayoutNode

@end

@interface MLNUIInnerScrollViewContentStack : MLNUIPlaneStack

@property (nonatomic, strong) MLNUIScrollViewNodeRequestLayoutHandler requestLayout;

@end

@implementation MLNUIInnerScrollViewContentStack

- (instancetype)initWithDirection:(BOOL)horizontal requetLayoutHandler:(nonnull MLNUIScrollViewNodeRequestLayoutHandler)handler {
    if (self = [super init]) {
        self.mlnui_layoutNode.flexDirection = horizontal ? MLNUIFlexDirectionRow : MLNUIFlexDirectionColumn;
        self.clipsToBounds = YES;
        _requestLayout = handler;
    }
    return self;
}

#pragma mark - Override

- (BOOL)mlnui_isRootView {
    return YES;
}

- (BOOL)mlnui_allowVirtualLayout {
    return NO;
}

- (Class)mlnui_bindedLayoutNodeClass {
    return [MLNUIInnerScrollViewContentStackNode class];
}

- (void)setCrossAxisSize:(CGSize)size {
    MLNUILayoutNode *node = [self mlnui_layoutNode];
    switch (node.flexDirection) {
        case MLNUIFlexDirectionRow:
        case MLNUIFlexDirectionRowReverse:
            node.height = MLNUIPointValue(size.height);
            break;
        case MLNUIFlexDirectionColumn:
        case MLNUIFlexDirectionColumnReverse:
            node.width = MLNUIPointValue(size.width);
            break;
        default:
            break;
    }
}

- (void)setCrossAxisMaxSize:(CGSize)maxSize {
    MLNUILayoutNode *node = [self mlnui_layoutNode];
    switch (node.flexDirection) {
        case MLNUIFlexDirectionRow:
        case MLNUIFlexDirectionRowReverse:
            node.maxHeight = MLNUIPointValue(maxSize.height);
            break;
        case MLNUIFlexDirectionColumn:
        case MLNUIFlexDirectionColumnReverse:
            node.maxWidth = MLNUIPointValue(maxSize.width);
            break;
        default:
            break;
    }
}

@end

@implementation MLNUIInnerScrollViewContentStackNode

#pragma mark - Override

- (CGSize)applyLayout {
    MLNUIInnerScrollViewContentStack *stack = (MLNUIInnerScrollViewContentStack *)self.view;
    if (stack && stack.requestLayout) {
        return stack.requestLayout();
    }
    return CGSizeZero;
}

@end


@interface MLNUIInnerScrollView()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) MLNUILuaCore *mlnui_luaCore;
@property (nonatomic, strong) MLNUIScrollViewDelegate *luaui_delegate;

@end

@implementation MLNUIInnerScrollView

+ (void)load {
    [self argoui_installScrollViewPanGestureConflictHandler];
}

#pragma mark - Override

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore direction:(BOOL)horizontal requetLayoutHandler:(nonnull MLNUIScrollViewNodeRequestLayoutHandler)handler {
    if (self = [self initWithMLNUILuaCore:luaCore isHorizontal:horizontal]) {
        self.luaui_delegate = [[MLNUIScrollViewDelegate alloc] init];
        self.delegate = self.luaui_delegate;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self createStackContentViewIfNeed:horizontal requetLayoutHandler:handler];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && self.mlnui_contentView) {
        [self luaui_addSubview:self.mlnui_contentView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize contentSize = self.mlnui_contentView.frame.size;
    self.contentSize = contentSize;
    if (self.mlnui_horizontal) {
        if (contentSize.height > self.frame.size.height) {
            [self.superview mlnui_markNeedsLayout]; // 水平滚动，contentSize.height大于父视图，要重新计算布局，以修正父视图大小
        }
    } else {
        if (contentSize.width > self.frame.size.width) {
            [self.superview mlnui_markNeedsLayout]; // 竖直滚动，contentSize.width大于父视图，要重新计算布局，以修正父视图大小
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:self.panGestureRecognizer.class] &&
        [otherGestureRecognizer isKindOfClass:self.panGestureRecognizer.class]) {
        UIScrollView *view1 = (UIScrollView *)gestureRecognizer.view;
        UIScrollView *view2 = (UIScrollView *)otherGestureRecognizer.view;
        if (view1.argoui_isVerticalDirection == view2.argoui_isVerticalDirection) {
            return YES;
        }
        return NO;
    }
    return NO;
}

#pragma mark - Private

- (void)createStackContentViewIfNeed:(BOOL)horizontal requetLayoutHandler:(nonnull MLNUIScrollViewNodeRequestLayoutHandler)handler {
    if (self.mlnui_contentView) {
        return;
    }
    MLNUIInnerScrollViewContentStack *stack = [[MLNUIInnerScrollViewContentStack alloc] initWithDirection:horizontal requetLayoutHandler:handler];
    self.mlnui_contentView = stack;
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) addRootnode:stack.mlnui_layoutNode];
}

#pragma mark - Override

- (BOOL)luaui_isContainer {
    return YES;
}

@end
