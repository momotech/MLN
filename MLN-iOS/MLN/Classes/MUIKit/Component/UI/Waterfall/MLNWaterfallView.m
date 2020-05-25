//
//  MLNWaterfallView.m
//  
//
//  Created by MoMo on 2018/8/31.
//

#import "MLNWaterfallView.h"
#import "MLNViewExporterMacro.h"
#import "MLNCollectionViewCell.h"
#import "MLNWaterfallLayout.h"
#import "MLNInternalWaterfallView.h"
#import "MLNWaterfallAdapter.h"
#import "MLNBlock.h"
#import "MLNBeforeWaitingTask.h"
#import "UIScrollView+MLNKit.h"
#import "MLNKitHeader.h"
#import "UIView+MLNLayout.h"
#import "MLNCollectionViewLayoutProtocol.h"
#import "UIView+MLNKit.h"

@interface MLNWaterfallView()
@property (nonatomic, strong, readwrite) MLNInternalWaterfallView *innerWaterfallView;
@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;
@property (nonatomic, strong) UICollectionViewLayout *layout;
@end

@implementation MLNWaterfallView
@synthesize adapter = _adapter;

- (void)mln_user_data_dealloc
{
    // 去除强引用
    MLN_Lua_UserData_Release(self.adapter);
    // 去除强引用
    MLN_Lua_UserData_Release(self.layout);
    [super mln_user_data_dealloc];
}

#pragma mark - Header
- (void)lua_addHeaderView:(UIView *)headerview
{
    MLNKitLuaAssert(NO, @"WaterfallView:addHeaderView method is deprecated, use WaterfallAdapter:initHeader and WaterfallAdapter:fillHeaderData methods instead!");
    [self.innerWaterfallView setHeaderView:headerview];
    [self.innerWaterfallView reloadData];
}

- (void)lua_removeHeaderView
{
    MLNKitLuaAssert(NO, @"WaterfallView:removeHeaderView method is deprecated, use WaterfallAdapter:headerValid method instead!");
    [self.innerWaterfallView resetHeaderView];
    [self.innerWaterfallView reloadData];
}

- (void)lua_useAllSpanForLoading:(BOOL)useAllSpanForLoading
{
    // Android中加载是否占用一行，默认不占用；iOS空实现
}

#pragma mark - Getter & setter
- (MLNBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            if (sself.innerWaterfallView.delegate != sself.adapter) {
                sself.innerWaterfallView.delegate = sself.adapter;
            }
            if (sself.innerWaterfallView.dataSource != sself.adapter) {
                sself.innerWaterfallView.dataSource = sself.adapter;
            }
            [sself.innerWaterfallView reloadData];
        }];
    }
    return _lazyTask;
}

- (void)setAdapter:(id<MLNCollectionViewAdapterProtocol>)adapter
{
    MLNCheckTypeAndNilValue(adapter, @"WaterfallAdapter", [MLNWaterfallAdapter class])
    if (_adapter != adapter) {
        // 去除强引用
        MLN_Lua_UserData_Release(_adapter);
        // 添加强引用
        MLN_Lua_UserData_Retain_With_Index(2, adapter);
        _adapter = adapter;
        [self mln_pushLazyTask:self.lazyTask];
    }
}

- (void)lua_setCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if (_layout != layout) {
        // 去除强引用
        MLN_Lua_UserData_Release(_layout);
        // 添加强引用
        MLN_Lua_UserData_Retain_With_Index(2, layout);
        _layout = layout;
        self.innerWaterfallView.collectionViewLayout = layout;
    }
    
}

- (UICollectionViewLayout *)lua_collectionViewLayout
{
    return self.innerWaterfallView.collectionViewLayout;
}

- (void)lua_setScrollDirection:(MLNScrollDirection)scrollDirection
{
    MLNKitLuaAssert(NO, @"WaterfallView does not setting scrollDirction!");
}

- (MLNScrollDirection)lua_scrollDirection
{
    return self.innerWaterfallView.mln_horizontal? MLNScrollDirectionHorizontal : MLNScrollDirectionVertical;
}

- (void)lua_showScrollIndicator:(BOOL)show
{
    self.innerWaterfallView.showsVerticalScrollIndicator = show;
    self.innerWaterfallView.showsHorizontalScrollIndicator = show;
}

- (BOOL)lua_isShowScrollIndicator
{
    return self.innerWaterfallView.showsHorizontalScrollIndicator && self.innerWaterfallView.showsVerticalScrollIndicator;
}

#pragma mark - Scroll
- (void)lua_scrollToCell:(NSInteger)row section:(NSInteger)section animation:(BOOL)animate
{
    if (!self.innerWaterfallView.scrollEnabled) {
        return;
    }
    NSInteger realSection = section - 1;
    NSInteger realRow = row - 1;
    NSInteger sectionCount = [self.innerWaterfallView numberOfSections];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerWaterfallView numberOfItemsInSection:realSection];
        MLNKitLuaAssert(realRow >= 0 && realRow < count, @"This row number is wrong!");
        if (realRow >= 0 && realRow < count) {
            [self.innerWaterfallView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:realRow inSection:realSection] atScrollPosition:UICollectionViewScrollPositionTop animated:animate];
        }
    }
}

- (void)lua_scrollToTop:(BOOL)animated
{
    if (self.innerWaterfallView.scrollEnabled) {
        [self.innerWaterfallView setContentOffset:CGPointZero animated:animated];
    }
}

- (BOOL)lua_scrollIsTop
{
    return self.innerWaterfallView.contentOffset.y + self.innerWaterfallView.contentInset.top <= 0;
}

- (CGPoint)lua_pointAtIndexPath:(NSInteger)row section:(NSInteger)section
{
    NSInteger realRow = row - 1;
    NSInteger realSection = section - 1;
    NSInteger sectionCount = [self.innerWaterfallView numberOfSections];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger rowCount = [self.innerWaterfallView numberOfItemsInSection:realSection];
        MLNKitLuaAssert(realRow >= 0 && realRow < rowCount, @"This row number is wrong!");
        if (realRow >= 0 && realRow < rowCount) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:realRow inSection:realSection];
            UICollectionViewLayoutAttributes *attributes = [self.innerWaterfallView layoutAttributesForItemAtIndexPath:indexPath];
            return attributes.frame.origin;
        }
    }
    return CGPointZero;
}

#pragma mark - Relaod
- (void)lua_reloadAtSection:(NSInteger)section animation:(BOOL)animation
{
    NSInteger sectionCount = [self.innerWaterfallView numberOfSections];
    NSInteger realSection = section - 1;
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:realSection];
        if ([self.adapter respondsToSelector:@selector(collectionView:reloadSections:)]) {
            [self.adapter collectionView:self.innerWaterfallView reloadSections:set];
        }
        if (animation) {
            [self.innerWaterfallView performBatchUpdates:^{
                [self.innerWaterfallView reloadSections:set];
            } completion:nil];
        } else {
            [UIView performWithoutAnimation:^{
                [self.innerWaterfallView reloadSections:set];
            }];
        }
    }
}

- (void)lua_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation
{
    NSInteger sectionCount = [self.innerWaterfallView numberOfSections];
    NSInteger realSection = section - 1;
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger rowCount = [self.innerWaterfallView numberOfItemsInSection:realSection];
        NSInteger realRow = row - 1;
        MLNKitLuaAssert(realRow >= 0 && realRow < rowCount, @"This row number is wrong!");
        if (realRow >= 0 && realRow < rowCount) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:realRow inSection:realSection];
            NSArray *indexPaths = @[indexPath];
            if ([self.adapter respondsToSelector:@selector(collectionView:reloadItemsAtIndexPaths:)]) {
                [self.adapter collectionView:self.innerWaterfallView reloadItemsAtIndexPaths:indexPaths];
            }
            if (animation) {
                [self.innerWaterfallView performBatchUpdates:^{
                    [self.innerWaterfallView reloadItemsAtIndexPaths:indexPaths];
                } completion:nil];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerWaterfallView reloadItemsAtIndexPaths:indexPaths];
                }];
            }
        }
    }
}

- (void)lua_reloadData
{
    if ([self.adapter respondsToSelector:@selector(collectionViewReloadData:)]) {
        [self.adapter collectionViewReloadData:self.innerWaterfallView];
    }
    [self.innerWaterfallView.collectionViewLayout invalidateLayout];
    [self.innerWaterfallView reloadData];
}

#pragma mark - Insert
- (void)lua_insertAtRow:(NSInteger)row section:(NSInteger)section
{
    [self lua_insertRow:row section:section animated:NO];
}

- (void)lua_insertRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self lua_insertRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)lua_insertCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self lua_insertRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)lua_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
{
    NSInteger realSection = section -1;
    NSInteger realStartRow = startRow -1;
    NSInteger realEndRow = endRow -1;
    NSInteger sectionCount = [self.adapter numberOfSectionsInCollectionView:self.innerWaterfallView];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerWaterfallView numberOfItemsInSection:realSection];
        MLNKitLuaAssert(realStartRow >= 0 && realEndRow >= realStartRow && realStartRow <= count, @"This row number is wrong!");
        
        if (realStartRow >= 0 && realStartRow <= realEndRow  && realStartRow <= count) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:realEndRow - realStartRow + 1];
            for (NSInteger i = realStartRow ; i <= realEndRow; i++) {
                NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:i inSection:realSection];
                [indexPaths addObject:anIndexPath];
            }
            if ([self.adapter respondsToSelector:@selector(collectionView:insertItemsAtSection:startItem:endItem:)]) {
                [self.adapter collectionView:self.innerWaterfallView insertItemsAtSection:realSection startItem:realStartRow endItem:realEndRow];
            }
            if (animated) {
                [self.innerWaterfallView performBatchUpdates:^{
                    [self.innerWaterfallView insertItemsAtIndexPaths:indexPaths];
                } completion:nil];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerWaterfallView insertItemsAtIndexPaths:indexPaths];
                }];
            }
        }
    }
}

#pragma mark - Delete
- (void)lua_deleteAtRow:(NSInteger)row section:(NSInteger)section
{
    [self lua_deleteRow:row section:section animated:NO];
}

- (void)lua_deleteRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self lua_deleteRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)lua_deleteCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self lua_deleteRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)lua_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
{
    NSInteger realSection = section -1;
    NSInteger realStartRow = startRow -1;
    NSInteger realEndRow = endRow -1;
    NSInteger sectionCount = [self.adapter numberOfSectionsInCollectionView:self.innerWaterfallView];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger itemCount = [self.innerWaterfallView numberOfItemsInSection:realSection];
        MLNKitLuaAssert(realStartRow >= 0 && realStartRow <= realEndRow && realEndRow < itemCount, @"This row number is wrong");
        
        if (realStartRow >= 0 && realStartRow <= realEndRow && realEndRow < itemCount) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:realEndRow - realStartRow + 1];
            for (NSInteger i = realStartRow ; i <= realEndRow; i++) {
                NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:i inSection:realSection];
                [indexPaths addObject:anIndexPath];
            }
            if ([self.adapter respondsToSelector:@selector(collectionView:deleteItemsAtSection:startItem:endItem:indexPaths:)]) {
                [self.adapter collectionView:self.innerWaterfallView deleteItemsAtSection:realSection startItem:realStartRow endItem:realEndRow indexPaths:indexPaths];
            }
            if (animated) {
                [self.innerWaterfallView performBatchUpdates:^{
                    [self.innerWaterfallView deleteItemsAtIndexPaths:indexPaths];
                } completion:nil];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerWaterfallView deleteItemsAtIndexPaths:indexPaths];
                }];
            }
        }
    }
}

- (MLNLuaTable* )lua_cellAt:(NSInteger)section row:(NSInteger)row
{
    NSInteger trueSection = section - 1;
    NSInteger trueRow = row - 1;
    if (trueSection < 0 || trueRow < 0) {
        return nil;
    }
    MLNCollectionViewCell* cell = (MLNCollectionViewCell*)[self.innerWaterfallView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:trueRow inSection:trueSection]];
    MLNKitLuaAssert([cell respondsToSelector:@selector(getLuaTable)], @"collection cell must realize gutLuaTable function");
    if (cell) {
        MLNLuaTable* table = [cell getLuaTable];
        return table;
    }
    return nil;
}

- (NSMutableArray *)lua_visibleCells
{
    NSMutableArray* arrayT = [NSMutableArray array];
    for (MLNCollectionViewCell* cell in [self.innerWaterfallView visibleCells]) {
        if ([cell respondsToSelector:@selector(getLuaTable)]) {
            MLNLuaTable* table = [cell getLuaTable];
            if (table) {
                [arrayT addObject:table];
            }
        }
    }
    return arrayT;
}

#pragma mark - Override
- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return CGSizeMake(maxWidth, maxHeight);
}

- (UIView *)lua_contentView
{
    return self.innerWaterfallView;
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

- (void)lua_addSubview:(UIView *)view
{
    MLNKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (void)lua_setShowsHorizontalScrollIndicator:(BOOL)show
{
    MLNKitLuaAssert(NO, @"CollectionView does not supoort this method!");
}

- (BOOL)lua_showsHorizontalScrollIndicator
{
    MLNKitLuaAssert(NO, @"CollectionView does not supoort this method!");
    return NO;
}

- (void)lua_setShowsVerticalScrollIndicator:(BOOL)show
{
    MLNKitLuaAssert(NO, @"CollectionView does not supoort this method!");
}

- (BOOL)lua_showsVerticalScrollIndicator
{
    MLNKitLuaAssert(NO, @"CollectionView does not supoort this method!");
    return NO;
}

#pragma mark - Gesture
- (void)handleLongPress:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gesture locationInView:self];
    NSIndexPath *indexPath = [self.innerWaterfallView indexPathForItemAtPoint:p];
    if (indexPath && [self.adapter respondsToSelector:@selector(collectionView:longPressItemAtIndexPath:)]) {
        [self.adapter collectionView:self.innerWaterfallView longPressItemAtIndexPath:indexPath];
    }
}


#pragma mark - Getters

- (MLNInternalWaterfallView *)innerWaterfallView
{
    if (!_innerWaterfallView) {
        MLNWaterfallLayout *layout = [[MLNWaterfallLayout alloc] init];
        _innerWaterfallView = [[MLNInternalWaterfallView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _innerWaterfallView.containerView = self;
        _innerWaterfallView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _innerWaterfallView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 10.0, *)) {
            _innerWaterfallView.prefetchingEnabled = NO;
        }
        [self addSubview:_innerWaterfallView];
        
        // fix:父视图添加tapGesture、longPressGesture手势WaterfallView点击、长按回调不响应的问题
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration  = 0.5;
        [_innerWaterfallView addGestureRecognizer:lpgr];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        [tapGesture requireGestureRecognizerToFail:lpgr];
        tapGesture.cancelsTouchesInView = NO;
        [_innerWaterfallView addGestureRecognizer:tapGesture];
    }
    return _innerWaterfallView;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNWaterfallView)
LUA_EXPORT_VIEW_METHOD(addHeaderView, "lua_addHeaderView:", MLNWaterfallView)
LUA_EXPORT_VIEW_METHOD(removeHeaderView, "lua_removeHeaderView", MLNWaterfallView)
LUA_EXPORT_METHOD(useAllSpanForLoading, "lua_useAllSpanForLoading:", MLNWaterfallView)
LUA_EXPORT_VIEW_END(MLNWaterfallView, WaterfallView, YES, "MLNCollectionView", "initWithLuaCore:refreshEnable:loadEnable:")
@end
