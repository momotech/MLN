//
//  MLNUIWaterfallHeaderView.m
//
//
//  Created by MoMo on 2019/5/10.
//

#import "MLNUIWaterfallHeaderView.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"

@interface MLNUIWaterfallHeaderView()

@property (nonatomic, strong) MLNUIReuseContentView *luaContentView;

@end

@implementation MLNUIWaterfallHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView)
    [self.luaContentView luaui_addSubview:view];
}

#pragma mark - MLNUIReuseCellProtocol
//- (void)pushContentViewWithLuaCore:(MLNUILuaCore *)luaCore
//{
//    [self.luaContentView pushToLuaCore:luaCore];
//}

- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore {
    return [self.luaContentView createLuaTableAsCellNameForLuaIfNeed:luaCore];
}

- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize {
    [self.luaContentView createLayoutNodeIfNeedWithFitSize:fitSize maxSize:maxSize];
}

//- (void)updateLuaContentViewIfNeed
//{
//    [self.luaContentView updateFrameIfNeed];
//}

- (MLNUILuaTable *)getLuaTable
{
    return self.luaContentView.luaTable;
}

- (BOOL)isInited
{
    return self.luaContentView.isInited;
}

- (void)initCompleted
{
    [self.luaContentView setInited:YES];
}

- (CGSize)caculateCellSizeWithMaxSize:(CGSize)maxSize apply:(BOOL)apply {
    return [self.luaContentView caculateContentViewSizeWithMaxSize:maxSize apply:apply];
}

- (CGSize)caculateCellSizeWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize apply:(BOOL)apply {
    return [self.luaContentView caculateContentViewSizeWithFitSize:fitSize maxSize:maxSize apply:apply];
}

- (void)mlnui_requestLayoutIfNeed
{
    [self.luaContentView mlnui_requestLayoutIfNeed];
}

- (void)updateLastReueseId:(NSString *)lastReuaseId
{
    self.luaContentView.lastReuaseId = lastReuaseId;
}

- (NSString *)lastReueseId
{
    return self.luaContentView.lastReuaseId;
}

#pragma mark - Getter
- (MLNUIReuseContentView *)luaContentView
{
    if (!_luaContentView) {
        _luaContentView = [[MLNUIReuseContentView alloc] initWithFrame:CGRectZero cellView:self];
        [self addSubview:_luaContentView];
    }
    return _luaContentView;
}

@end
