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

- (void)mlnui_user_data_dealloc
{
    // 去除强引用
    MLNUI_Lua_UserData_Release(self.adapter);
    // 去除强引用
    MLNUI_Lua_UserData_Release(self.layout);
    [super mlnui_user_data_dealloc];
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
            [sself mlnui_handleCollectionViewStatus];
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
        _adapter.collectionView = self.innerCollectionView;
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)luaui_setCollectionViewLayout:(UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)layout
{
    MLNUICheckTypeAndNilValue(layout, @"CollectionViewGridLayout", [UICollectionViewLayout class])
    if (_layout != layout) {
        // 去除强引用
        MLNUI_Lua_UserData_Release(_layout);
        // 添加强引用
        MLNUI_Lua_UserData_Retain_With_Index(2, layout);
        layout.scrollDirection = self.innerCollectionView.mlnui_horizontal? MLNUIScrollDirectionHorizontal : MLNUIScrollDirectionVertical;
        _layout = layout;
        self.innerCollectionView.collectionViewLayout = layout;
    }
}

- (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)luaui_collectionViewLayout
{
    return (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)self.innerCollectionView.collectionViewLayout;
}

- (void)luaui_setScrollDirection:(MLNUIScrollDirection)scrollDirection
{
    [self mlnui_in_setScrollDirection:scrollDirection];
}

- (MLNUIScrollDirection)luaui_scrollDirection
{
    return [self mlnui_in_scrollDirection];
}

- (void)luaui_showScrollIndicator:(BOOL)show
{
    self.innerCollectionView.showsVerticalScrollIndicator = show;
    self.innerCollectionView.showsHorizontalScrollIndicator = show;
}

- (BOOL)luaui_isShowScrollIndicator
{
    return self.innerCollectionView.showsHorizontalScrollIndicator && self.innerCollectionView.showsVerticalScrollIndicator;
}

- (void)luaui_setDisallowFling:(BOOL)disable {
    self.innerCollectionView.luaui_disallowFling = disable;
}

- (BOOL)luaui_disallowFling {
    return self.innerCollectionView.luaui_disallowFling;
}

#pragma mark - direction

- (void)mlnui_in_setScrollDirection:(MLNUIScrollDirection)scrollDirection
{
    UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *layout = (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)self.innerCollectionView.collectionViewLayout;
    layout.scrollDirection = scrollDirection;
    self.innerCollectionView.mlnui_horizontal = scrollDirection == MLNUIScrollDirectionHorizontal;
}

- (MLNUIScrollDirection)mlnui_in_scrollDirection
{
   UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *layout = (UICollectionViewLayout<MLNUICollectionViewLayoutProtocol> *)self.innerCollectionView.collectionViewLayout;
    return layout.scrollDirection;
}

#pragma mark - Scroll
- (void)luaui_scrollToCell:(NSInteger)row section:(NSInteger)section animation:(BOOL)animate
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

- (void)luaui_scrollToTop:(BOOL)animated
{
    if (self.innerCollectionView.scrollEnabled) {
        [self.innerCollectionView setContentOffset:CGPointZero animated:animated];
    }
}

- (BOOL)luaui_scrollIsTop
{
    if ([self mlnui_in_scrollDirection] == UICollectionViewScrollDirectionVertical) {
        return self.innerCollectionView.contentOffset.y + self.innerCollectionView.contentInset.top <= 0;
    } else {
        return self.innerCollectionView.contentOffset.x + self.innerCollectionView.contentInset.left <= 0;
    }
}

- (CGPoint)luaui_pointAtIndexPath:(NSInteger)row section:(NSInteger)section
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
- (void)luaui_reloadAtSection:(NSInteger)section animation:(BOOL)animation
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

- (void)luaui_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation
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

- (void)luaui_reloadData
{
    if ([self.adapter respondsToSelector:@selector(collectionViewReloadData:)]) {
        [self.adapter collectionViewReloadData:self.innerCollectionView];
    }
    [self.innerCollectionView.collectionViewLayout invalidateLayout];
    [self.innerCollectionView reloadData];
}

#pragma mark - Insert
- (void)luaui_insertAtRow:(NSInteger)row section:(NSInteger)section
{
    [self luaui_insertRow:row section:section animated:NO];
}

- (void)luaui_insertRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self luaui_insertRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)luaui_insertCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self luaui_insertRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)luaui_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
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
- (void)luaui_deleteAtRow:(NSInteger)row section:(NSInteger)section
{
    [self luaui_deleteRow:row section:section animated:NO];
}

- (void)luaui_deleteRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self luaui_deleteRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)luaui_deleteCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self luaui_deleteRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)luaui_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
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

- (MLNUILuaTable* )luaui_cellAt:(NSInteger)section row:(NSInteger)row
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

- (NSMutableArray *)luaui_visibleCells
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

- (void)mlnui_handleCollectionViewStatus
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.missionRow && strongSelf.missionSection) {
            [strongSelf luaui_scrollToCell:strongSelf.missionRow section:strongSelf.missionSection animation:strongSelf.missionAnimated];
            strongSelf.missionRow = 0;
            strongSelf.missionSection = 0;
            strongSelf.missionAnimated = NO;
        }
    });
}

#pragma mark - Override

- (void)mlnui_layoutCompleted {
    [super mlnui_layoutCompleted];
    id<MLNUICollectionViewLayoutProtocol> layout = (id<MLNUICollectionViewLayoutProtocol>)((UICollectionView *)self.mlnui_contentView).collectionViewLayout;
    [layout relayoutIfNeed];
}

- (CGSize)mlnui_sizeThatFits:(CGSize)size {
    return size;
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)luaui_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (void)luaui_setShowsHorizontalScrollIndicator:(BOOL)show
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
}

- (BOOL)luaui_showsHorizontalScrollIndicator
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
    return NO;
}

- (void)luaui_setShowsVerticalScrollIndicator:(BOOL)show
{
    MLNUIKitLuaAssert(NO, @"CollectionView does not supoort this method!");
}

- (BOOL)luaui_showsVerticalScrollIndicator
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

#pragma mark - MLNUIPaddingContainerViewProtocol

- (UIView *)mlnui_contentView
{
    return self.innerCollectionView;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(adapter, "setAdapter:", "adapter", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(layout, "luaui_setCollectionViewLayout:","luaui_collectionViewLayout", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(openReuseCell, "setLuaui_openReuseCell:","luaui_openReuseCell", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(scrollDirection, "luaui_setScrollDirection:","luaui_scrollDirection", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(showScrollIndicator, "luaui_showScrollIndicator:","luaui_isShowScrollIndicator", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "luaui_setShowsHorizontalScrollIndicator:", "luaui_showsHorizontalScrollIndicator", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "luaui_setShowsVerticalScrollIndicator:", "luaui_showsVerticalScrollIndicator", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(disallowFling, "luaui_setDisallowFling:", "luaui_disallowFling", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(reloadData, "luaui_reloadData", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(reloadAtRow, "luaui_reloadAtRow:section:animation:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(reloadAtSection, "luaui_reloadAtSection:animation:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(scrollToCell, "luaui_scrollToCell:section:animation:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(scrollToTop, "luaui_scrollToTop:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(isStartPosition, "luaui_scrollIsTop", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(deleteCellAtRow, "luaui_deleteAtRow:section:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(insertCellAtRow, "luaui_insertAtRow:section:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(insertCellsAtSection, "luaui_insertCellsAtSection:startRow:endRow:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(deleteCellsAtSection, "luaui_deleteCellsAtSection:startRow:endRow:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(pointAtIndexPath, "luaui_pointAtIndexPath:section:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(deleteRow, "luaui_deleteRow:section:animated:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(insertRow, "luaui_insertRow:section:animated:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(insertRowsAtSection, "luaui_insertRowsAtSection:startRow:endRow:animated:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(deleteRowsAtSection, "luaui_deleteRowsAtSection:startRow:endRow:animated:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(cellWithSectionRow, "luaui_cellAt:row:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(visibleCells, "luaui_visibleCells", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setScrollEnable, "mlnui_setLuaScrollEnable:", MLNUICollectionView)
// refresh header
LUAUI_EXPORT_VIEW_PROPERTY(refreshEnable, "setLuaui_refreshEnable:", "luaui_refreshEnable", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(isRefreshing, "luaui_isRefreshing", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(startRefreshing, "luaui_startRefreshing", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(stopRefreshing, "luaui_stopRefreshing", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setRefreshingCallback, "setLuaui_refreshCallback:", MLNUICollectionView)
// load footer
LUAUI_EXPORT_VIEW_PROPERTY(loadEnable, "setLuaui_loadEnable:", "luaui_loadEnable", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(isLoading, "luaui_isLoading", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(stopLoading, "luaui_stopLoading", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(noMoreData, "luaui_noMoreData", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(resetLoading, "luaui_resetLoading", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(loadError, "luaui_loadError", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setLoadingCallback, "setLuaui_loadCallback:", MLNUICollectionView)
// ScrollView callback
LUAUI_EXPORT_VIEW_METHOD(padding, "luaui_setPaddingWithTop:right:bottom:left:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(loadThreshold, "setLuaui_loadahead:", "luaui_loadahead", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLuaui_scrollBeginCallback:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setScrollingCallback, "setLuaui_scrollingCallback:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLuaui_endDraggingCallback:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLuaui_startDeceleratingCallback:",MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLuaui_scrollEndCallback:",MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setContentInset, "luaui_setContentInset:right:bottom:left:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(getContentInset, "luaui_getContetnInset:", MLNUICollectionView)
// private method
LUAUI_EXPORT_VIEW_PROPERTY(contentOffset, "luaui_setContentOffset:", "luaui_contentOffset", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(pagerContentOffset, "luaui_setPagerContentOffset:y:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(i_bounces, "luaui_setBounces:", "luaui_bounces", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "luaui_setAlwaysBounceHorizontal:", "luaui_alwaysBounceHorizontal", MLNUICollectionView)
LUAUI_EXPORT_VIEW_PROPERTY(i_bounceVertical, "luaui_setAlwaysBounceVertical:", "luaui_alwaysBounceVertical", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "luaui_setScrollIndicatorInset:right:bottom:left:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_METHOD(setOffsetWithAnim, "luaui_setContentOffsetWithAnimation:", MLNUICollectionView)
LUAUI_EXPORT_VIEW_END(MLNUICollectionView, CollectionView, YES, "MLNUIView", "initWithMLNUILuaCore:refreshEnable:loadEnable:")

@end
