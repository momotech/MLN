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
#import "MLNUILinearLayout.h"
#import "MLNUILuaCore.h"
#import "MLNUILayoutNode.h"
#import "UIView+MLNUILayout.h"
#import "UIView+MLNUIKit.h"

@interface MLNUIInnerScrollView()

@property(nonatomic, weak) MLNUILuaCore *mlnui_luaCore;
@property (nonatomic, strong) MLNUIScrollViewDelegate *luaui_delegate;
@property (nonatomic, assign, getter=isLinearContenView, readonly) BOOL linearContenView;

@end

@implementation MLNUIInnerScrollView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore direction:(BOOL)horizontal isLinearContenView:(BOOL)isLinearContenView
{
    if (self = [self initWithMLNUILuaCore:luaCore isHorizontal:horizontal]) {
        _linearContenView = isLinearContenView;
        self.luaui_delegate = [[MLNUIScrollViewDelegate alloc] init];
        self.delegate = self.luaui_delegate;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self createLinearLayoutIfNeed];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && self.mlnui_contentView) {
        [self luaui_addSubview:self.mlnui_contentView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self recalculContentSizeIfNeed];
}

- (void)recalculContentSizeIfNeed
{
    CGSize contentSize = self.contentSize;
    if (!self.mlnui_horizontal) {
        if (contentSize.width > self.frame.size.width && self.frame.size.width != 0) {
            contentSize.width = self.frame.size.width;
            self.contentSize = contentSize;
        }
    }
    else {
        if (contentSize.height > self.frame.size.height && self.frame.size.height != 0) {
            contentSize.height = self.frame.size.height;
            self.contentSize = contentSize;
        }
    }
}

- (void)updateContentViewLayoutIfNeed
{
    if (self.luaui_node.isDirty) {
        [self.mlnui_contentView luaui_needLayout];
    }
}

#pragma mark - Private method
- (void)createLinearLayoutIfNeed
{
    if (self.isLinearContenView && !self.mlnui_contentView) {
        self.mlnui_contentView = [self createLinearLayoutWithDirection:self.mlnui_horizontal];
        self.mlnui_contentView.clipsToBounds = YES;
    }
}

- (MLNUILinearLayout *)createLinearLayoutWithDirection:(MLNUIScrollDirection)direction
{
    switch (direction) {
        case MLNUIScrollDirectionHorizontal: {
            MLNUILinearLayout *linear = [[MLNUILinearLayout alloc] initWithLayoutDirection:MLNUILayoutDirectionHorizontal];
            linear.luaui_height = MLNUILayoutMeasurementTypeMatchParent;
            return linear;
        }
        default: {
            MLNUILinearLayout *linear = [[MLNUILinearLayout alloc] initWithLayoutDirection:MLNUILayoutDirectionVertical];
            linear.luaui_width = MLNUILayoutMeasurementTypeMatchParent;
            return linear;
        }
    }
}

#pragma mark - Override
- (BOOL)luaui_layoutEnable
{
    return YES;
}

- (BOOL)luaui_isContainer
{
    return YES;
}

@end
