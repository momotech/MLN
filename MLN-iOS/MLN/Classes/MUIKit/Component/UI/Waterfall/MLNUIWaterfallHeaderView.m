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
- (void)pushContentViewWithLuaCore:(MLNUILuaCore *)luaCore
{
    [self.luaContentView pushToLuaCore:luaCore];
}

- (void)setupLayoutNodeIfNeed
{
    [self.luaContentView setupLayoutNodeIfNeed];
}

- (void)updateLuaContentViewIfNeed
{
    [self.luaContentView updateFrameIfNeed];
}

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

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight
{
    return [self.luaContentView calculHeightWithWidth:width maxHeight:maxHeight];
}

- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return [self.luaContentView calculSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
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
