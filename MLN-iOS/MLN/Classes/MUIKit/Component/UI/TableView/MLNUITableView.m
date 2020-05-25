//
//  MMTableView.m
//  MLNUI
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNUITableView.h"
#import "MLNUIInnerTableView.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUITableViewAdapter.h"
#import "MLNUITableViewCell.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"
#import "MLNUIBeforeWaitingTask.h"
#import "MLNUISizeCahceManager.h"
#import "MLNUIInnerTableView.h"
#import "UIView+MLNUIKit.h"
#import "NSObject+MLNUICore.h"

@interface MLNUITableView()
@property (nonatomic, strong) MLNUIInnerTableView *innerTableView;
@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;
@end

@implementation MLNUITableView

- (void)mlnui_user_data_dealloc
{
    // 去除强引用
    MLNUI_Lua_UserData_Release(self.adapter);
    [super mlnui_user_data_dealloc];
}

#pragma mark - Getter
- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            if (sself.innerTableView.delegate != sself.adapter) {
                sself.innerTableView.delegate = sself.adapter;
            }
            if (sself.innerTableView.dataSource != sself.adapter) {
                sself.innerTableView.dataSource = sself.adapter;
            }
            [sself.innerTableView reloadData];
        }];
    }
    return _lazyTask;
}

#pragma mark - Export To Lua
- (void)setAdapter:(id<UITableViewDelegate,UITableViewDataSource, MLNUITableViewAdapterProtocol>)adapter
{
    if (_adapter != adapter) {
        // 去除强引用
        MLNUI_Lua_UserData_Release(_adapter);
        // 添加强引用
        MLNUI_Lua_UserData_Retain_With_Index(2, adapter);
        _adapter = adapter;
        _adapter.targetTableView = self.innerTableView;
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)luaui_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation
{
    MLNUIKitLuaAssert(section > 0, @"This section number is wrong!");
    MLNUIKitLuaAssert(row > 0, @"This row number is wrong!");
    if (section > 0 && row > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:section-1];
        if ([self.adapter respondsToSelector:@selector(tableView:reloadRowsAtIndexPaths:)]) {
            [self.adapter tableView:self.innerTableView reloadRowsAtIndexPaths:@[indexPath]];
        }
        if (animation) {
            [self.innerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [UIView performWithoutAnimation:^{
                [self.innerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
}

- (void)luaui_reloadAtSection:(NSInteger)section animation:(BOOL)animation
{
    MLNUIKitLuaAssert(section > 0, @"This section number is wrong!");
    if (section > 0) {
        NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section-1];
        if ([self.adapter respondsToSelector:@selector(tableView:reloadSections:)]) {
            [self.adapter tableView:self.innerTableView reloadSections:sections];
        }
        if (animation) {
            [self.innerTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [UIView performWithoutAnimation:^{
                [self.innerTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
}

- (void)luaui_showScrollIndicator:(BOOL)show
{
    self.innerTableView.showsVerticalScrollIndicator = show;
}

- (void)luaui_scrollToTop:(BOOL)animated
{
    if (self.innerTableView.scrollEnabled) {
        [self.innerTableView setContentOffset:CGPointZero animated:animated];
    }
}

- (BOOL)luaui_scrollIsTop {
    return self.innerTableView.contentOffset.y + self.innerTableView.contentInset.top <= 0;
}

- (void)luaui_scrollToRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    if (!self.innerTableView.scrollEnabled) {
        return;
    }
    NSInteger realSection = section - 1;
    NSInteger realRow = row - 1;
    NSInteger sectionCount = [self.innerTableView numberOfSections];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerTableView numberOfRowsInSection:realSection];
        MLNUIKitLuaAssert(realRow >= 0 && realRow < count, @"This row number is wrong!");
        if (realRow >= 0 && realRow < count) {
            [self.innerTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:realRow inSection:realSection] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
}


#pragma mark - Insert
- (void)luaui_insertAtRow:(NSInteger)row section:(NSInteger)section
{
    [self luaui_insertCellsAtSection:section startRow:row endRow:row];
}

- (void)luaui_insertCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self luaui_insertRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)luaui_insertRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self luaui_insertRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)luaui_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
{
    NSInteger realSection = section -1;
    NSInteger realStartRow = startRow - 1;
    NSInteger realEndRow = endRow - 1;
    NSInteger sectionCount = [self.adapter numberOfSectionsInTableView:self.innerTableView];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount , @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerTableView numberOfRowsInSection:realSection];
        MLNUIKitLuaAssert((0 <= realStartRow && realStartRow <= count && realStartRow <= realEndRow), @"This row number is wrong!");
        
        if (0 <= realStartRow && realStartRow <= count && realStartRow <= realEndRow) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:realEndRow - realStartRow + 1];
            for (NSInteger i = realStartRow ; i <= realEndRow; i++) {
                NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:i inSection:realSection];
                [indexPaths addObject:anIndexPath];
            }
            if ([self.adapter respondsToSelector:@selector(tableView:insertRowsAtSection:startItem:endItem:)]) {
                [self.adapter tableView:self.innerTableView insertRowsAtSection:realSection startItem:realStartRow endItem:realEndRow];
            }
            if (animated) {
                if (@available(iOS 11, *)) {
                    [self.innerTableView performBatchUpdates:^{
                        [self.innerTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    } completion:nil];
                } else {
                    [self.innerTableView beginUpdates];
                    [self.innerTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [self.innerTableView endUpdates];
                }
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                }];
            }
        }
    }
}

#pragma mark - Delete
- (void)luaui_deleteAtRow:(NSInteger)row section:(NSInteger)section
{
    [self luaui_deleteCellsAtSection:section startRow:row endRow:row];
}

- (void)luaui_deleteCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self luaui_deleteRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)luaui_deleteRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self luaui_deleteRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)luaui_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
{
    NSInteger realSection = section - 1;
    NSInteger realStartRow = startRow - 1;
    NSInteger realEndRow = endRow - 1;
    NSInteger sectionCount = [self.adapter numberOfSectionsInTableView:self.innerTableView];
    MLNUIKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerTableView numberOfRowsInSection:realSection];
        MLNUIKitLuaAssert(0 <= realStartRow && realStartRow <= realEndRow && realEndRow < count, @"This row number is wrong!");
        
        if (0 <= realStartRow && realStartRow <= realEndRow && realEndRow < count) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:realEndRow - realStartRow + 1];
            for (NSInteger i = realStartRow ; i <= realEndRow; i++) {
                NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:i inSection:realSection];
                [indexPaths addObject:anIndexPath];
            }
            if ([self.adapter respondsToSelector:@selector(tableView:deleteRowsAtSection:startItem:endItem:indexPaths:)]) {
                [self.adapter tableView:self.innerTableView deleteRowsAtSection:realSection startItem:realStartRow endItem:realEndRow indexPaths:indexPaths];
            }
            if (animated) {
                if (@available(iOS 11, *)) {
                    [self.innerTableView performBatchUpdates:^{
                        [self.innerTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    } completion:nil];
                } else {
                    [self.innerTableView beginUpdates];
                    [self.innerTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [self.innerTableView endUpdates];
                }
            } else {
                [UIView performWithoutAnimation:^{
                    [self.innerTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                }];
            }
        }
    }
}

- (MLNUILuaTable *)luaui_cellAt:(NSInteger)section row:(NSInteger)row {
    NSInteger trueSection = section - 1;
    NSInteger trueRow = row - 1;
    if (trueSection < 0 || trueRow < 0) {
        return nil;
    }
    MLNUITableViewCell* cell = [self.innerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trueRow inSection:trueSection]];
    MLNUIKitLuaAssert([cell respondsToSelector:@selector(getLuaTable)], @"tableView cell must realize gutLuaTable function");
    if (cell) {
        MLNUILuaTable* table = [cell getLuaTable];
        return table;
    }
    return nil;
}

- (NSMutableArray *)luaui_visibleCells
{
    NSMutableArray* arrayT = [NSMutableArray array];
    for (MLNUITableViewCell* cell in [self.innerTableView visibleCells]) {
        if ([cell respondsToSelector:@selector(getLuaTable)]) {
            MLNUILuaTable* table = [cell getLuaTable];
            if (table) {
                [arrayT addObject:table];
            }
        }
    }
    return arrayT;
}

- (void)luaui_reloadData
{
    if ([self.adapter respondsToSelector:@selector(tableViewReloadData:)]) {
        [self.adapter tableViewReloadData:self.innerTableView];
    }
    [self.innerTableView reloadData];
}

#pragma mark - Override

- (CGSize)luaui_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return CGSizeMake(maxWidth, maxHeight);
}

- (BOOL)luaui_layoutEnable
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
    MLNUIKitLuaAssert(NO, @"TableView does not supoort this method!");
}

- (BOOL)luaui_showsHorizontalScrollIndicator
{
    MLNUIKitLuaAssert(NO, @"TableView does not supoort this method!");
    return NO;
}

- (void)luaui_setShowsVerticalScrollIndicator:(BOOL)show
{
    MLNUIKitLuaAssert(NO, @"TableView does not supoort this method!");
}

- (BOOL)luaui_showsVerticalScrollIndicator
{
    MLNUIKitLuaAssert(NO, @"TableView does not supoort this method!");
    return NO;
}

#pragma mark - Gesture
- (void)handleLongPress:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gesture locationInView:self.innerTableView];
    NSIndexPath *indexPath = [self.innerTableView indexPathForRowAtPoint:p];
    if (indexPath && [self.adapter respondsToSelector:@selector(tableView:longPressRowAtIndexPath:)]) {
        [self.adapter tableView:self.innerTableView longPressRowAtIndexPath:indexPath];
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self.innerTableView];
    NSIndexPath *indexPath = [self.innerTableView indexPathForRowAtPoint:p];
    if (indexPath && [self.adapter respondsToSelector:@selector(tableView:singleTapSelectRowAtIndexPath:)]) {
        [self.adapter tableView:self.innerTableView singleTapSelectRowAtIndexPath:indexPath];
    }
}

#pragma - MLNUIPaddingViewProtocol
- (UITableView *)innerTableView
{
    if (!_innerTableView) {
        _innerTableView = [[MLNUIInnerTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        if (@available(iOS 11.0, *)) {
            _innerTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _innerTableView.estimatedRowHeight = 0.f;
            _innerTableView.estimatedSectionFooterHeight = 0.f;
            _innerTableView.estimatedSectionHeaderHeight = 0.f;
        }
        _innerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _innerTableView.backgroundColor = [UIColor clearColor];
        _innerTableView.containerView = self;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration  = 0.5;
        lpgr.cancelsTouchesInView = NO;
        [_innerTableView addGestureRecognizer:lpgr];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        tapGesture.cancelsTouchesInView = NO;
        [tapGesture requireGestureRecognizerToFail:lpgr];
        [_innerTableView addGestureRecognizer:tapGesture];
        
        [self addSubview:_innerTableView];
    }
    
    return _innerTableView;
}

- (UIView *)luaui_contentView
{
    return self.innerTableView;
}


#pragma mark - Setup For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(adapter, "setAdapter:", "adapter", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(openReuseCell, "setLuaui_openReuseCell:","luaui_openReuseCell", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "luaui_setShowsHorizontalScrollIndicator:", "luaui_showsHorizontalScrollIndicator", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "luaui_setShowsVerticalScrollIndicator:", "luaui_showsVerticalScrollIndicator", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(showScrollIndicator, "luaui_showScrollIndicator:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(reloadData, "luaui_reloadData", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(reloadAtRow, "luaui_reloadAtRow:section:animation:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(reloadAtSection, "luaui_reloadAtSection:animation:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(scrollToTop, "luaui_scrollToTop:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(scrollToCell, "luaui_scrollToRow:section:animated:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(deleteCellAtRow, "luaui_deleteAtRow:section:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(insertCellAtRow, "luaui_insertAtRow:section:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(deleteCellsAtSection, "luaui_deleteCellsAtSection:startRow:endRow:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(insertCellsAtSection, "luaui_insertCellsAtSection:startRow:endRow:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(insertRow, "luaui_insertRow:section:animated:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(deleteRow, "luaui_deleteRow:section:animated:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(insertRowsAtSection, "luaui_insertRowsAtSection:startRow:endRow:animated:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(deleteRowsAtSection, "luaui_deleteRowsAtSection:startRow:endRow:animated:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(isStartPosition, "luaui_scrollIsTop", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(cellWithSectionRow, "luaui_cellAt:row:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(visibleCells, "luaui_visibleCells", MLNUITableView)
// refresh header
LUA_EXPORT_VIEW_PROPERTY(refreshEnable, "setLuaui_refreshEnable:", "luaui_refreshEnable", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(isRefreshing, "luaui_isRefreshing", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(startRefreshing, "luaui_startRefreshing", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(stopRefreshing, "luaui_stopRefreshing", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setRefreshingCallback, "setLuaui_refreshCallback:", MLNUITableView)
// load footer
LUA_EXPORT_VIEW_PROPERTY(loadEnable, "setLuaui_loadEnable:", "luaui_loadEnable", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(isLoading, "luaui_isLoading", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(stopLoading, "luaui_stopLoading", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(noMoreData, "luaui_noMoreData", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(resetLoading, "luaui_resetLoading", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(loadError, "luaui_loadError", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setLoadingCallback, "setLuaui_loadCallback:", MLNUITableView)
// scrollView callback
LUA_EXPORT_VIEW_PROPERTY(loadThreshold, "setLuaui_loadahead:", "luaui_loadahead", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLuaui_scrollBeginCallback:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setScrollingCallback, "setLuaui_scrollingCallback:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLuaui_endDraggingCallback:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLuaui_startDeceleratingCallback:",MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLuaui_scrollEndCallback:",MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setContentInset, "luaui_setContentInset:right:bottom:left:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(getContentInset, "luaui_getContetnInset:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setScrollEnable, "mlnui_setLuaScrollEnable:", MLNUITableView)
// deprected method
LUA_EXPORT_VIEW_PROPERTY(contentSize, "luaui_setContentSize:", "luaui_contentSize", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(scrollEnabled, "luaui_setScrollEnabled:", "luaui_scrollEnabled", MLNUITableView)
// private method
LUA_EXPORT_VIEW_PROPERTY(contentOffset, "luaui_setContentOffset:", "luaui_contentOffset", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(i_bounces, "luaui_setBounces:", "luaui_bounces", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "luaui_setAlwaysBounceHorizontal:", "luaui_alwaysBounceHorizontal", MLNUITableView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceVertical, "luaui_setAlwaysBounceVertical:", "luaui_alwaysBounceVertical", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "luaui_setScrollIndicatorInset:right:bottom:left:", MLNUITableView)
LUA_EXPORT_VIEW_METHOD(setOffsetWithAnim, "luaui_setContentOffsetWithAnimation:", MLNUITableView)
LUA_EXPORT_VIEW_END(MLNUITableView, TableView, YES, "MLNUIView", "initWithMLNUILuaCore:refreshEnable:loadEnable:")

@end
