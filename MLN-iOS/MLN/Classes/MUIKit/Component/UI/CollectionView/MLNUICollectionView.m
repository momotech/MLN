//
//  MLNUICollectionView.m
//  
//
//  Created by MoMo on 2018/7/9.
//

#import "MLNUICollectionView.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIScrollView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"
#import "MLNUIBeforeWaitingTask.h"
#import "MLNUISizeCahceManager.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUICollectionViewAdapter.h"
#import "MLNUIInnerCollectionView.h"
#import "MLNUICollectionViewLayoutProtocol.h"
#import "UIView+MLNUIKit.h"
#import "MLNUICollectionViewLayoutProtocol.h"

@interface MLNUICollectionView()
@property (nonatomic, strong) MLNUIInnerCollectionView *innerCollectionView;
@property (nonatomic, assign) MLNUIScrollDirection scrollDirection;
@property (nonatomic, strong) UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *layout;
@property (nonatomic, assign) NSInteger missionRow;
@property (nonatomic, assign) NSInteger missionSection;
@property (nonatomic, assign) BOOL missionAnimated;
@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;

@end

@implementation MLNUICollectionView

- (void)mln_user_data_dealloc
{
    // 去除强引用
    MLNUI_Lua_UserData_Release(self.adapter);
    // 去除强引用
    MLNUI_Lua_UserData_Release(self.layout);
    [super mln_user_data_dealloc];
}

#pragma mark - Getter & setter
- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            if (sself.innerCollectionView.delegate != sself.adapter) {
                sself.innerCollectionView.delegate = sself.adapter;
            }
            if (sself.innerCollectionView.dataSource != sself.adapter) {
                sself.innerCollectionView.dataSource = sself.adapter;
            }
            [sself mln_handleCollectionViewStatus];
        }];
    }
    return _lazyTask;
}

- (void)setAdapter:(id<MLNUICollectionViewAdapterProtocol>)adapter
{
    MLNUICheckTypeAndNilValue(adapter, @"CollectionViewAdapter", [MLNUICollectionViewAdapter class])
    if (_adapter != adapter) {
        // 去除强引用
        MLNUI_Lua_UserData_Release(_adapter);
        // 添加强引用
        MLNUI_Lua_UserData_Retain_With_Index(2, adapter);
        _adapter = adapter;
        [self mln_pushLazyTask:self.lazyTask];
    }
}

- (void)lua_setCollectionViewLayout:(UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)layout
{
    MLNUICheckTypeAndNilValue(layout, @"CollectionViewGridLayout", [UICollectionViewLayout class])
    if (_layout != layout) {
        // 去除强引用
        MLNUI_Lua_UserData_Release(_layout);
        // 添加强引用
        MLNUI_Lua_UserData_Retain_With_Index(2, layout);
        layout.scrollDirection = self.innerCollectionView.mln_horizontal? MLNUIScrollDirectionHorizontal : MLNUIScrollDirectionVertical;
        _layout = layout;
        self.innerCollectionView.collectionViewLayout = layout;
    }
}

- (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)lua_collectionViewLayout
{
    return (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)self.innerCollectionView.collectionViewLayout;
}

- (void)lua_setScrollDirection:(MLNUIScrollDirection)scrollDirection
{
    [self mln_in_setScrollDirection:scrollDirection];
}

- (MLNUIScrollDirection)lua_scrollDirection
{
    return [self mln_in_scrollDirection];
}

- (void)lua_showScrollIndicator:(BOOL)show
{
    self.innerCollectionView.showsVerticalScrollIndicator = show;
    self.innerCollectionView.showsHorizontalScrollIndicator = show;
}

- (BOOL)lua_isShowScrollIndicator
{
    return self.innerCollectionView.showsHorizontalScrollIndicator && self.innerCollectionView.showsVerticalScrollIndicator;
}

#pragma mark - direction

- (void)mln_in_setScrollDirection:(MLNUIScrollDirection)scrollDirection
{
    UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *layout = (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)self.innerCollectionView.collectionViewLayout;
    layout.scrollDirection = scrollDirection;
    self.innerCollectionView.mln_horizontal = scrollDirection == MLNUIScrollDirectionHorizontal;
}

- (MLNUIScrollDirection)mln_in_scrollDirection
{
   UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *layout = (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)self.innerCollectionView.collectionViewLayout;
    return layout.scrollDirection;
}

#pragma mark - Scroll
- (void)lua_scrollToCell:(NSInteger)row section:(NSInteger)section animation:(BOOL)animate
{
    if (CGSizeEqualToSize(self.innerCollectionView.contentSize, CGSizeZero)) {
        _missionRow = row;
        _missionSection = section;
        _missionAnimated = animate;
        return;
    }
    if (!self.innerCollectionView.scrollEnabled) {
        return;
    }
    NSInteger realSection = section - 1;
    NSInteger realRow = row - 1;
    NSInteger sectionCount = [self.innerCollectionView numberOfSections];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerCollectionView numberOfItemsInSection:realSection];
        MLNUIKitLuaAssert(realRow >= 0 && realRow < count, @"This row number is wrong!");
        if (realRow >= 0 && realRow < count) {
            [self.innerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:realRow inSection:realSection] atScrollPosition:UICollectionViewScrollPositionTop animated:animate];
        }
    }
}

- (void)lua_scrollToTop:(BOOL)animated
{
    if (self.innerCollectionView.scrollEnabled) {
        [self.innerCollectionView setContentOffset:CGPointZero animated:animated];
    }
}

- (BOOL)lua_scrollIsTop
{
    if ([self mln_in_scrollDirection] == UICollectionViewScrollDirectionVertical) {
        return self.innerCollectionView.contentOffset.y + self.innerCollectionView.contentInset.top <= 0;
    } else {
        return self.innerCollectionView.contentOffset.x + self.innerCollectionView.contentInset.left <= 0;
    }
}

- (CGPoint)lua_pointAtIndexPath:(NSInteger)row section:(NSInteger)section
{
    NSInteger realRow = row - 1;
    NSInteger realSection = section - 1;
    NSInteger sectionCount = [self.innerCollectionView numberOfSections];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger rowCount = [self.innerCollectionView numberOfItemsInSection:realSection];
        MLNUIKitLuaAssert(realRow >= 0 && realRow < rowCount, @"This row number is wrong!");
        if (realRow >= 0 && realRow < rowCount) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:realRow inSection:realSection];
            UICollectionViewLayoutAttributes *attributes = [self.innerCollectionView layoutAttributesForItemAtIndexPath:indexPath];
            return attributes.frame.origin;
        }
    }
    return CGPointZero;
}

#pragma mark - Relaod
- (void)lua_reloadAtSection:(NSInteger)section animation:(BOOL)animation
{
    NSInteger sectionCount = [self.innerCollectionView numberOfSections];
    NSInteger realSection = section - 1;
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:realSection];
        if ([self.adapter respondsToSelector:@selector(collectionView:reloadSections:)]) {
            [self.adapter collectionView:self.innerCollectionView reloadSections:set];
        }
        if (animation) {
            [self.innerCollectionView performBatchUpdates:^{
                [self.innerCollectionView reloadSections:set];
            } completion:nil];
        } else {
            [UIView performWithoutAnimation:^{
                [self.innerCollectionView reloadSections:set];
            }];
        }
    }
}

- (void)lua_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation
{
    NSInteger sectionCount = [self.innerCollectionView numberOfSections];
    NSInteger realSection = section - 1;
    MLNUIKitLuaAssert(realSection >= 0  && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0  && realSection < sectionCount) {
        NSInteger rowCount = [self.innerCollectionView numberOfItemsInSection:realSection];
        NSInteger realRow = row - 1;
        MLNUIKitLuaAssert(realRow >= 0 && realRow < rowCount, @"This row number is wrong!");
        if (realRow >= 0 && realRow < rowCount) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:realRow inSection:realSection];
            NSArray *indexPaths = @[indexPath];
            if ([self.adapter respondsToSelector:@selector(collectionView:reloadItemsAtIndexPaths:)]) {
                [self.adapter collectionView:self.innerCollectionView reloadItemsAtIndexPaths:indexPaths];
            }
            if (animation) {
                [self.innerCollectionView performBatchUpdates:^{
                    [self.innerCollectionView reloadItemsAtIndexPaths:indexPaths];
                } completion:nil];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerCollectionView reloadItemsAtIndexPaths:indexPaths];
                }];
            }
        }
    }
}

- (void)lua_reloadData
{
    if ([self.adapter respondsToSelector:@selector(collectionViewReloadData:)]) {
        [self.adapter collectionViewReloadData:self.innerCollectionView];
    }
    [self.innerCollectionView.collectionViewLayout invalidateLayout];
    [self.innerCollectionView reloadData];
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
    NSInteger sectionCount = [self.adapter numberOfSectionsInCollectionView:self.innerCollectionView];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerCollectionView numberOfItemsInSection:realSection];
        MLNUIKitLuaAssert(realStartRow >= 0 && realEndRow >= realStartRow && realStartRow <= count, @"This row number is wrong!");
        
        if (realStartRow >= 0 && realStartRow <= realEndRow  && realStartRow <= count) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:realEndRow - realStartRow + 1];
            for (NSInteger i = realStartRow ; i <= realEndRow; i++) {
                NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:i inSection:realSection];
                [indexPaths addObject:anIndexPath];
            }
            if ([self.adapter respondsToSelector:@selector(collectionView:insertItemsAtSection:startItem:endItem:)]) {
                [self.adapter collectionView:self.innerCollectionView insertItemsAtSection:realSection startItem:realStartRow endItem:realEndRow];
            }
            if (animated) {
                [self.innerCollectionView performBatchUpdates:^{
                    [self.innerCollectionView insertItemsAtIndexPaths:indexPaths];
                } completion:nil];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerCollectionView insertItemsAtIndexPaths:indexPaths];
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
    NSInteger sectionCount = [self.adapter numberOfSectionsInCollectionView:self.innerCollectionView];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger itemCount = [self.innerCollectionView numberOfItemsInSection:realSection];
        MLNUIKitLuaAssert(realStartRow >= 0 && realStartRow <= realEndRow && realEndRow < itemCount, @"This row number is wrong");
        
        if (realStartRow >= 0 && realStartRow <= realEndRow && realEndRow < itemCount) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:realEndRow - realStartRow + 1];
            for (NSInteger i = realStartRow ; i <= realEndRow; i++) {
                NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:i inSection:realSection];
                [indexPaths addObject:anIndexPath];
            }
            if ([self.adapter respondsToSelector:@selector(collectionView:deleteItemsAtSection:startItem:endItem:indexPaths:)]) {
                [self.adapter collectionView:self.innerCollectionView deleteItemsAtSection:realSection startItem:realStartRow endItem:realEndRow indexPaths:indexPaths];
            }
            if (animated) {
                [self.innerCollectionView performBatchUpdates:^{
                    [self.innerCollectionView deleteItemsAtIndexPaths:indexPaths];
                } completion:nil];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerCollectionView deleteItemsAtIndexPaths:indexPaths];
                }];
            }
        }
    }
}

- (MLNUILuaTable* )lua_cellAt:(NSInteger)section row:(NSInteger)row
{
    NSInteger trueSection = section - 1;
    NSInteger trueRow = row - 1;
    if (trueSection < 0 || trueRow < 0) {
        return nil;
    }
    MLNUICollectionViewCell* cell = (MLNUICollectionViewCell*)[self.innerCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:trueRow inSection:trueSection]];
    MLNUIKitLuaAssert([cell respondsToSelector:@selector(getLuaTable)], @"collection cell must realize gutLuaTable function");
    if (cell) {
        MLNUILuaTable* table = [cell getLuaTable];
        return table;
    }
    return nil;
}

- (NSMutableArray *)lua_visibleCells
{
    NSMutableArray* arrayT = [NSMutableArray array];
    for (MLNUICollectionViewCell* cell in [self.innerCollectionView visibleCells]) {
        if ([cell respondsToSelector:@selector(getLuaTable)]) {
            MLNUILuaTable *table = [cell getLuaTable];
            if (table) {
                [arrayT addObject:table];
            }
        }
    }
    return arrayT;
}

- (void)mln_handleCollectionViewStatus
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.missionRow && strongSelf.missionSection) {
            [strongSelf lua_scrollToCell:strongSelf.missionRow section:strongSelf.missionSection animation:strongSelf.missionAnimated];
            strongSelf.missionRow = 0;
            strongSelf.missionSection = 0;
            strongSelf.missionAnimated = NO;
        }
    });
}

#pragma mark - Override
- (void)lua_layoutCompleted
{
    [super lua_layoutCompleted];
    id<MLNUICollectionViewLayoutProtocol> layout = (id<MLNUICollectionViewLayoutProtocol>)((UICollectionView *)self.lua_contentView).collectionViewLayout;
    [layout relayoutIfNeed];
}

- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return CGSizeMake(maxWidth, maxHeight);
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

- (void)lua_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (void)lua_setShowsHorizontalScrollIndicator:(BOOL)show
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
}

- (BOOL)lua_showsHorizontalScrollIndicator
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
    return NO;
}

- (void)lua_setShowsVerticalScrollIndicator:(BOOL)show
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
}

- (BOOL)lua_showsVerticalScrollIndicator
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
    return NO;
}

#pragma mark - Gesture
- (void)handleLongPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gesture locationInView:self];
    NSIndexPath *indexPath = [self.innerCollectionView indexPathForItemAtPoint:p];
    if (indexPath && [self.adapter respondsToSelector:@selector(collectionView:longPressItemAtIndexPath:)]) {
        [self.adapter collectionView:self.innerCollectionView longPressItemAtIndexPath:indexPath];
    }
}

#pragma mark - Getters

- (UICollectionView *)innerCollectionView
{
    if (!_innerCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _innerCollectionView = [[MLNUIInnerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _innerCollectionView.containerView = self;
        if (@available(iOS 11.0, *)) {
            _innerCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 10.0, *)) {
            _innerCollectionView.prefetchingEnabled = NO;
        }
        _innerCollectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_innerCollectionView];
        
        // fix:父视图添加tapGesture、longPressGesture手势CollectionView点击、长按回调不响应的问题
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration  = 0.5;
        [_innerCollectionView addGestureRecognizer:lpgr];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        [tapGesture requireGestureRecognizerToFail:lpgr];
        tapGesture.cancelsTouchesInView = NO;
        [_innerCollectionView addGestureRecognizer:tapGesture];
    }
    return _innerCollectionView;
}

- (UIView *)lua_contentView
{
    return self.innerCollectionView;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(adapter, "setAdapter:", "adapter", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(layout, "lua_setCollectionViewLayout:","lua_collectionViewLayout", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(openReuseCell, "setLua_openReuseCell:","lua_openReuseCell", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(scrollDirection, "lua_setScrollDirection:","lua_scrollDirection", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(showScrollIndicator, "lua_showScrollIndicator:","lua_isShowScrollIndicator", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "lua_setShowsHorizontalScrollIndicator:", "lua_showsHorizontalScrollIndicator", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "lua_setShowsVerticalScrollIndicator:", "lua_showsVerticalScrollIndicator", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(reloadData, "lua_reloadData", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(reloadAtRow, "lua_reloadAtRow:section:animation:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(reloadAtSection, "lua_reloadAtSection:animation:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(scrollToCell, "lua_scrollToCell:section:animation:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(scrollToTop, "lua_scrollToTop:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(isStartPosition, "lua_scrollIsTop", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(deleteCellAtRow, "lua_deleteAtRow:section:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(insertCellAtRow, "lua_insertAtRow:section:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(insertCellsAtSection, "lua_insertCellsAtSection:startRow:endRow:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(deleteCellsAtSection, "lua_deleteCellsAtSection:startRow:endRow:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(pointAtIndexPath, "lua_pointAtIndexPath:section:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(deleteRow, "lua_deleteRow:section:animated:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(insertRow, "lua_insertRow:section:animated:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(insertRowsAtSection, "lua_insertRowsAtSection:startRow:endRow:animated:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(deleteRowsAtSection, "lua_deleteRowsAtSection:startRow:endRow:animated:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(cellWithSectionRow, "lua_cellAt:row:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(visibleCells, "lua_visibleCells", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setScrollEnable, "mln_setLuaScrollEnable:", MLNUICollectionView)
// refresh header
LUA_EXPORT_VIEW_PROPERTY(refreshEnable, "setLua_refreshEnable:", "lua_refreshEnable", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(isRefreshing, "lua_isRefreshing", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(startRefreshing, "lua_startRefreshing", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(stopRefreshing, "lua_stopRefreshing", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setRefreshingCallback, "setLua_refreshCallback:", MLNUICollectionView)
// load footer
LUA_EXPORT_VIEW_PROPERTY(loadEnable, "setLua_loadEnable:", "lua_loadEnable", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(isLoading, "lua_isLoading", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(stopLoading, "lua_stopLoading", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(noMoreData, "lua_noMoreData", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(resetLoading, "lua_resetLoading", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(loadError, "lua_loadError", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setLoadingCallback, "setLua_loadCallback:", MLNUICollectionView)
// ScrollView callback
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPaddingWithTop:right:bottom:left:", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(loadThreshold, "setLua_loadahead:", "lua_loadahead", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLua_scrollBeginCallback:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setScrollingCallback, "setLua_scrollingCallback:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLua_endDraggingCallback:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLua_startDeceleratingCallback:",MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLua_scrollEndCallback:",MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setContentInset, "lua_setContentInset:right:bottom:left:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(getContentInset, "lua_getContetnInset:", MLNUICollectionView)
// deprected method
LUA_EXPORT_VIEW_PROPERTY(contentSize, "lua_setContentSize:", "lua_contentSize", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(scrollEnabled, "lua_setScrollEnabled:", "lua_scrollEnabled", MLNUICollectionView)
// private method
LUA_EXPORT_VIEW_PROPERTY(contentOffset, "lua_setContentOffset:", "lua_contentOffset", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(i_bounces, "lua_setBounces:", "lua_bounces", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "lua_setAlwaysBounceHorizontal:", "lua_alwaysBounceHorizontal", MLNUICollectionView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceVertical, "lua_setAlwaysBounceVertical:", "lua_alwaysBounceVertical", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "lua_setScrollIndicatorInset:right:bottom:left:", MLNUICollectionView)
LUA_EXPORT_VIEW_METHOD(setOffsetWithAnim, "lua_setContentOffsetWithAnimation:", MLNUICollectionView)
LUA_EXPORT_VIEW_END(MLNUICollectionView, CollectionView, YES, "MLNUIView", "initWithLuaCore:refreshEnable:loadEnable:")

@end
