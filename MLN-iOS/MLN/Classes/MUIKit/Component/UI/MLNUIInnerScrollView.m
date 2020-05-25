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

@property(nonatomic, weak) MLNUILuaCore *mln_luaCore;
@property (nonatomic, strong) MLNUIScrollViewDelegate *lua_delegate;
@property (nonatomic, assign, getter=isLinearContenView, readonly) BOOL linearContenView;

@end

@implementation MLNUIInnerScrollView

- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore direction:(BOOL)horizontal isLinearContenView:(BOOL)isLinearContenView
{
    if (self = [self initWithLuaCore:luaCore isHorizontal:horizontal]) {
        _linearContenView = isLinearContenView;
        self.lua_delegate = [[MLNUIScrollViewDelegate alloc] init];
        self.delegate = self.lua_delegate;
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
    
    if (newSuperview && self.mln_contentView) {
        [self lua_addSubview:self.mln_contentView];
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
    if (!self.mln_horizontal) {
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
    if (self.lua_node.isDirty) {
        [self.mln_contentView lua_needLayout];
    }
}

#pragma mark - Private method
- (void)createLinearLayoutIfNeed
{
    if (self.isLinearContenView && !self.mln_contentView) {
        self.mln_contentView = [self createLinearLayoutWithDirection:self.mln_horizontal];
        self.mln_contentView.clipsToBounds = YES;
    }
}

- (MLNUILinearLayout *)createLinearLayoutWithDirection:(MLNUIScrollDirection)direction
{
    switch (direction) {
        case MLNUIScrollDirectionHorizontal: {
            MLNUILinearLayout *linear = [[MLNUILinearLayout alloc] initWithLayoutDirection:MLNUILayoutDirectionHorizontal];
            linear.lua_height = MLNUILayoutMeasurementTypeMatchParent;
            return linear;
        }
        default: {
            MLNUILinearLayout *linear = [[MLNUILinearLayout alloc] initWithLayoutDirection:MLNUILayoutDirectionVertical];
            linear.lua_width = MLNUILayoutMeasurementTypeMatchParent;
            return linear;
        }
    }
}

#pragma mark - Override
- (BOOL)lua_layoutEnable
{
    return YES;
}

- (BOOL)lua_isContainer
{
    return YES;
}

@end
