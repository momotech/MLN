//
//  MLNInnerScrollView.m
//  MLN
//
//  Created by MoMo on 2019/11/1.
//

#import "MLNInnerScrollView.h"
#import "MLNScrollViewDelegate.h"
#import "UIScrollView+MLNKit.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"
#import "MLNLinearLayout.h"
#import "MLNLuaCore.h"
#import "MLNLayoutNode.h"
#import "UIView+MLNLayout.h"
#import "UIView+MLNKit.h"

@interface MLNInnerScrollView()

@property(nonatomic, weak) MLNLuaCore *mln_luaCore;
@property (nonatomic, strong) MLNScrollViewDelegate *lua_delegate;
@property (nonatomic, assign, getter=isLinearContenView, readonly) BOOL linearContenView;

@end

@implementation MLNInnerScrollView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore direction:(BOOL)horizontal isLinearContenView:(BOOL)isLinearContenView
{
    if (self = [self initWithLuaCore:luaCore isHorizontal:horizontal]) {
        _linearContenView = isLinearContenView;
        self.lua_delegate = [[MLNScrollViewDelegate alloc] init];
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

- (MLNLinearLayout *)createLinearLayoutWithDirection:(MLNScrollDirection)direction
{
    switch (direction) {
        case MLNScrollDirectionHorizontal: {
            MLNLinearLayout *linear = [[MLNLinearLayout alloc] initWithLayoutDirection:MLNLayoutDirectionHorizontal];
            linear.lua_height = MLNLayoutMeasurementTypeMatchParent;
            return linear;
        }
        default: {
            MLNLinearLayout *linear = [[MLNLinearLayout alloc] initWithLayoutDirection:MLNLayoutDirectionVertical];
            linear.lua_width = MLNLayoutMeasurementTypeMatchParent;
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
