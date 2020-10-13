//
//  MLNUIWaterfallHeaderView.m
//
//
//  Created by MoMo on 2019/5/10.
//

#import "MLNUIWaterfallHeaderView.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"

@interface MLNUIWaterfallHeaderView()<MLNUIReuseCellProtocol>

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

- (Class)reuseContentViewClass {
    return [MLNUIReuseContentView class];
}

- (void)reloadHeaderViewIfNeededWithSize:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(mlnuiWaterfallViewHeaderViewShouldReload:size:)]) {
        [self.delegate mlnuiWaterfallViewHeaderViewShouldReload:self size:size];
    }
}

#pragma mark - MLNUIReuseCellProtocol

- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore {
    return [self.luaContentView createLuaTableAsCellNameForLuaIfNeed:luaCore];
}

- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize {
    [self.luaContentView createLayoutNodeIfNeedWithFitSize:fitSize maxSize:maxSize];
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

- (void)updateLastReueseId:(NSString *)lastReuaseId
{
    self.luaContentView.lastReuaseId = lastReuaseId;
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

- (NSString *)lastReueseId
{
    return self.luaContentView.lastReuaseId;
}

#pragma mark - Getter
- (MLNUIReuseContentView *)luaContentView
{
    if (!_luaContentView) {
        _luaContentView = [[self.reuseContentViewClass alloc] initWithFrame:CGRectZero cellView:self];
        __weak typeof(self) weakSelf = self;
        _luaContentView.didChangeLayout = ^(CGSize size) {
            [weakSelf reloadHeaderViewIfNeededWithSize:size];
        };
        [self addSubview:_luaContentView];
    }
    return _luaContentView;
}

@end

@implementation MLNUIWaterfallAutoFitHeaderView

#pragma mark - Override

- (Class)reuseContentViewClass {
    return [MLNUIReuseAutoSizeContentView class];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attribute = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    if ([self.delegate respondsToSelector:@selector(mlnuiWaterfallAutoFitSizeForHeaderView:indexPath:)]) {
        CGSize size = [self.delegate mlnuiWaterfallAutoFitSizeForHeaderView:self indexPath:layoutAttributes.indexPath];
        CGRect frame = attribute.frame;
        frame.size = size;
        attribute.frame = frame;
    }
    return attribute;
}


@end
