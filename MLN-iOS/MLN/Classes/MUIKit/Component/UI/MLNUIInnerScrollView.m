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

@interface MLNUIInnerScrollView()

@property (nonatomic, weak) MLNUILuaCore *mlnui_luaCore;
@property (nonatomic, strong) MLNUIScrollViewDelegate *luaui_delegate;

@end

@implementation MLNUIInnerScrollView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore direction:(BOOL)horizontal isStackContenView:(BOOL)isStackContenView {
    if (self = [self initWithMLNUILuaCore:luaCore isHorizontal:horizontal]) {
        self.luaui_delegate = [[MLNUIScrollViewDelegate alloc] init];
        self.delegate = self.luaui_delegate;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (isStackContenView) {
            [self createStackContentViewIfNeed:horizontal];
        }
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
    self.contentSize = self.mlnui_contentView.frame.size;
}

- (void)updateContentViewLayoutIfNeed {
    if (self.mlnui_layoutNode.isDirty) {
        [self.mlnui_contentView mlnui_markNeedsLayout];
    }
}

#pragma mark - Private

- (void)createStackContentViewIfNeed:(BOOL)horizontal {
    if (self.mlnui_contentView) {
        return;
    }
    MLNUIStack *stack;
    if (horizontal) {
        stack = [[MLNUIHStack alloc] init];
        [stack setLuaui_height:MLNUILayoutMeasureMatchParent];
    } else {
        stack = [[MLNUIVStack alloc] init];
        [stack setLuaui_width:MLNUILayoutMeasureMatchParent];
    }
    stack.clipsToBounds = YES;
    self.mlnui_contentView = stack;
}

#pragma mark - Override

- (BOOL)mlnui_layoutEnable {
    return YES;
}

- (BOOL)luaui_isContainer {
    return YES;
}

@end
