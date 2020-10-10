//
//  MLNUICollectionViewCell.m
//
//
//  Created by MoMo on 2018/7/17.
//

#import "MLNUICollectionViewCell.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"
#import "MLNUILuaTable.h"

@interface MLNUICollectionViewCell ()

@property (nonatomic, strong) MLNUIReuseContentView *luaContentView;

@end

@implementation MLNUICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateContentViewFrameIfNeed
{
    //  reset content view frame if need
    if (self.isInited && !CGSizeEqualToSize(self.contentView.frame.size, self.frame.size)) {
        CGRect frame = self.contentView.frame;
        frame.size = self.frame.size;
        self.contentView.frame = frame;
    }
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUICheckTypeAndNilValue(view, @"View", [UIView class]);
    [self.luaContentView luaui_addSubview:view];
}

- (void)reloadCellIfNeededWithSize:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(mlnuiCollectionViewCellShouldReload:size:)]) {
        [self.delegate mlnuiCollectionViewCellShouldReload:self size:size];
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
        _luaContentView = [[self.reuseContentViewClass alloc] initWithFrame:CGRectZero cellView:self];
        __weak typeof(self) weakSelf = self;
        _luaContentView.didChangeLayout = ^(CGSize size) {
            [weakSelf reloadCellIfNeededWithSize:size];
        };
        [self.contentView addSubview:_luaContentView];
    }
    return _luaContentView;
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.luaContentView.luaTable.luaCore;
}

- (Class)reuseContentViewClass {
    return [MLNUIReuseContentView class];
}

@end

@implementation MLNUICollectionViewAutoSizeCell

#pragma mark - Override

- (Class)reuseContentViewClass {
    return [MLNUIReuseAutoSizeContentView class];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attribute = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    if ([self.delegate respondsToSelector:@selector(mlnuiCollectionViewAutoFitSizeForCell:indexPath:)]) {
        CGSize size = [self.delegate mlnuiCollectionViewAutoFitSizeForCell:self indexPath:layoutAttributes.indexPath];
        CGRect frame = attribute.frame;
        if (@available(iOS 10, *)) {
            frame.size = size;
        } else {
            frame.size = CGSizeMake(ceil(size.width), ceil(size.height));
        }
        attribute.frame = frame;
    }
    return attribute;
}

@end
