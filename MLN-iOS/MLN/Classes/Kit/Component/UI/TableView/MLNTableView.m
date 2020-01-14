//
//  MMTableView.m
//  MLN
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNTableView.h"
#import "MLNInnerTableView.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "UIScrollView+MLNKit.h"
#import "MLNTableViewAdapter.h"
#import "MLNTableViewCell.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNBeforeWaitingTask.h"
#import "MLNSizeCahceManager.h"
#import "MLNInnerTableView.h"
#import "UIView+MLNKit.h"
#import "NSObject+MLNCore.h"

@interface MLNTableView()
@property (nonatomic, strong) MLNInnerTableView *innerTableView;
@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;
@end

@implementation MLNTableView

- (void)mln_user_data_dealloc
{
    // 去除强引用
    MLN_Lua_UserData_Release(self.adapter);
    [super mln_user_data_dealloc];
}

#pragma mark - Getter
- (MLNBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNBeforeWaitingTask taskWithCallback:^{
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
- (void)setAdapter:(id<UITableViewDelegate,UITableViewDataSource, MLNTableViewAdapterProtocol>)adapter
{
    if (_adapter != adapter) {
        // 去除强引用
        MLN_Lua_UserData_Release(_adapter);
        // 添加强引用
        MLN_Lua_UserData_Retain_With_Index(2, adapter);
        _adapter = adapter;
        _adapter.targetTableView = self.innerTableView;
        [self mln_pushLazyTask:self.lazyTask];
    }
}

- (void)lua_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation
{
    MLNKitLuaAssert(section > 0, @"This section number is wrong!");
    MLNKitLuaAssert(row > 0, @"This row number is wrong!");
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

- (void)lua_reloadAtSection:(NSInteger)section animation:(BOOL)animation
{
    MLNKitLuaAssert(section > 0, @"This section number is wrong!");
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

- (void)lua_showScrollIndicator:(BOOL)show
{
    self.innerTableView.showsVerticalScrollIndicator = show;
}

- (void)lua_scrollToTop:(BOOL)animated
{
    if (self.innerTableView.scrollEnabled) {
        [self.innerTableView setContentOffset:CGPointZero animated:animated];
    }
}

- (BOOL)lua_scrollIsTop {
    return self.innerTableView.contentOffset.y + self.innerTableView.contentInset.top <= 0;
}

- (void)lua_scrollToRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    if (!self.innerTableView.scrollEnabled) {
        return;
    }
    NSInteger realSection = section - 1;
    NSInteger realRow = row - 1;
    NSInteger sectionCount = [self.innerTableView numberOfSections];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerTableView numberOfRowsInSection:realSection];
        MLNKitLuaAssert(realRow >= 0 && realRow < count, @"This row number is wrong!");
        if (realRow >= 0 && realRow < count) {
            [self.innerTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:realRow inSection:realSection] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
}


#pragma mark - Insert
- (void)lua_insertAtRow:(NSInteger)row section:(NSInteger)section
{
    [self lua_insertCellsAtSection:section startRow:row endRow:row];
}

- (void)lua_insertCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self lua_insertRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)lua_insertRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self lua_insertRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)lua_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
{
    NSInteger realSection = section -1;
    NSInteger realStartRow = startRow - 1;
    NSInteger realEndRow = endRow - 1;
    NSInteger sectionCount = [self.adapter numberOfSectionsInTableView:self.innerTableView];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount , @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerTableView numberOfRowsInSection:realSection];
        MLNKitLuaAssert((0 <= realStartRow && realStartRow <= count && realStartRow <= realEndRow), @"This row number is wrong!");
        
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
- (void)lua_deleteAtRow:(NSInteger)row section:(NSInteger)section
{
    [self lua_deleteCellsAtSection:section startRow:row endRow:row];
}

- (void)lua_deleteCellsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow
{
    [self lua_deleteRowsAtSection:section startRow:startRow endRow:endRow animated:NO];
}

- (void)lua_deleteRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated
{
    [self lua_deleteRowsAtSection:section startRow:row endRow:row animated:animated];
}

- (void)lua_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated
{
    NSInteger realSection = section - 1;
    NSInteger realStartRow = startRow - 1;
    NSInteger realEndRow = endRow - 1;
    NSInteger sectionCount = [self.adapter numberOfSectionsInTableView:self.innerTableView];
    MLNKitLuaAssert(realSection >= 0 && realSection < sectionCount, @"This section number is wrong!");
    
    if (realSection >= 0 && realSection < sectionCount) {
        NSInteger count = [self.innerTableView numberOfRowsInSection:realSection];
        MLNKitLuaAssert(0 <= realStartRow && realStartRow <= realEndRow && realEndRow < count, @"This row number is wrong!");
        
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

- (MLNLuaTable *)lua_cellAt:(NSInteger)section row:(NSInteger)row {
    NSInteger trueSection = section - 1;
    NSInteger trueRow = row - 1;
    if (trueSection < 0 || trueRow < 0) {
        return nil;
    }
    MLNTableViewCell* cell = [self.innerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trueRow inSection:trueSection]];
    MLNKitLuaAssert([cell respondsToSelector:@selector(getLuaTable)], @"tableView cell must realize gutLuaTable function");
    if (cell) {
        MLNLuaTable* table = [cell getLuaTable];
        return table;
    }
    return nil;
}

- (NSMutableArray *)lua_visibleCells
{
    NSMutableArray* arrayT = [NSMutableArray array];
    for (MLNTableViewCell* cell in [self.innerTableView visibleCells]) {
        if ([cell respondsToSelector:@selector(getLuaTable)]) {
            MLNLuaTable* table = [cell getLuaTable];
            if (table) {
                [arrayT addObject:table];
            }
        }
    }
    return arrayT;
}

- (void)lua_reloadData
{
    if ([self.adapter respondsToSelector:@selector(tableViewReloadData:)]) {
        [self.adapter tableViewReloadData:self.innerTableView];
    }
    [self.innerTableView reloadData];
}

#pragma mark - Override

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
    MLNKitLuaAssert(NO, @"TableView does not supoort this method!");
}

- (BOOL)lua_showsHorizontalScrollIndicator
{
    MLNKitLuaAssert(NO, @"TableView does not supoort this method!");
    return NO;
}

- (void)lua_setShowsVerticalScrollIndicator:(BOOL)show
{
    MLNKitLuaAssert(NO, @"TableView does not supoort this method!");
}

- (BOOL)lua_showsVerticalScrollIndicator
{
    MLNKitLuaAssert(NO, @"TableView does not supoort this method!");
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

#pragma - MLNPaddingViewProtocol
- (UITableView *)innerTableView
{
    if (!_innerTableView) {
        _innerTableView = [[MLNInnerTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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

- (UIView *)lua_contentView
{
    return self.innerTableView;
}


#pragma mark - Setup For Lua
LUA_EXPORT_VIEW_BEGIN(MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(adapter, "setAdapter:", "adapter", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(openReuseCell, "setLua_openReuseCell:","lua_openReuseCell", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "lua_setShowsHorizontalScrollIndicator:", "lua_showsHorizontalScrollIndicator", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "lua_setShowsVerticalScrollIndicator:", "lua_showsVerticalScrollIndicator", MLNTableView)
LUA_EXPORT_VIEW_METHOD(showScrollIndicator, "lua_showScrollIndicator:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(reloadData, "lua_reloadData", MLNTableView)
LUA_EXPORT_VIEW_METHOD(reloadAtRow, "lua_reloadAtRow:section:animation:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(reloadAtSection, "lua_reloadAtSection:animation:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(scrollToTop, "lua_scrollToTop:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(scrollToCell, "lua_scrollToRow:section:animated:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(deleteCellAtRow, "lua_deleteAtRow:section:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(insertCellAtRow, "lua_insertAtRow:section:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(deleteCellsAtSection, "lua_deleteCellsAtSection:startRow:endRow:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(insertCellsAtSection, "lua_insertCellsAtSection:startRow:endRow:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(insertRow, "lua_insertRow:section:animated:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(deleteRow, "lua_deleteRow:section:animated:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(insertRowsAtSection, "lua_insertRowsAtSection:startRow:endRow:animated:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(deleteRowsAtSection, "lua_deleteRowsAtSection:startRow:endRow:animated:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(isStartPosition, "lua_scrollIsTop", MLNTableView)
LUA_EXPORT_VIEW_METHOD(cellWithSectionRow, "lua_cellAt:row:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(visibleCells, "lua_visibleCells", MLNTableView)
// refresh header
LUA_EXPORT_VIEW_PROPERTY(refreshEnable, "setLua_refreshEnable:", "lua_refreshEnable", MLNTableView)
LUA_EXPORT_VIEW_METHOD(isRefreshing, "lua_isRefreshing", MLNTableView)
LUA_EXPORT_VIEW_METHOD(startRefreshing, "lua_startRefreshing", MLNTableView)
LUA_EXPORT_VIEW_METHOD(stopRefreshing, "lua_stopRefreshing", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setRefreshingCallback, "setLua_refreshCallback:", MLNTableView)
// load footer
LUA_EXPORT_VIEW_PROPERTY(loadEnable, "setLua_loadEnable:", "lua_loadEnable", MLNTableView)
LUA_EXPORT_VIEW_METHOD(isLoading, "lua_isLoading", MLNTableView)
LUA_EXPORT_VIEW_METHOD(stopLoading, "lua_stopLoading", MLNTableView)
LUA_EXPORT_VIEW_METHOD(noMoreData, "lua_noMoreData", MLNTableView)
LUA_EXPORT_VIEW_METHOD(resetLoading, "lua_resetLoading", MLNTableView)
LUA_EXPORT_VIEW_METHOD(loadError, "lua_loadError", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setLoadingCallback, "setLua_loadCallback:", MLNTableView)
// scrollView callback
LUA_EXPORT_VIEW_PROPERTY(loadThreshold, "setLua_loadahead:", "lua_loadahead", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLua_scrollBeginCallback:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setScrollingCallback, "setLua_scrollingCallback:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLua_endDraggingCallback:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLua_startDeceleratingCallback:",MLNTableView)
LUA_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLua_scrollEndCallback:",MLNTableView)
LUA_EXPORT_VIEW_METHOD(setContentInset, "lua_setContentInset:right:bottom:left:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(getContentInset, "lua_getContetnInset:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setScrollEnable, "mln_setLuaScrollEnable:", MLNTableView)
// deprected method
LUA_EXPORT_VIEW_PROPERTY(contentSize, "lua_setContentSize:", "lua_contentSize", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(scrollEnabled, "lua_setScrollEnabled:", "lua_scrollEnabled", MLNTableView)
// private method
LUA_EXPORT_VIEW_PROPERTY(contentOffset, "lua_setContentOffset:", "lua_contentOffset", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(i_bounces, "lua_setBounces:", "lua_bounces", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "lua_setAlwaysBounceHorizontal:", "lua_alwaysBounceHorizontal", MLNTableView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceVertical, "lua_setAlwaysBounceVertical:", "lua_alwaysBounceVertical", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "lua_setScrollIndicatorInset:right:bottom:left:", MLNTableView)
LUA_EXPORT_VIEW_METHOD(setOffsetWithAnim, "lua_setContentOffsetWithAnimation:", MLNTableView)
LUA_EXPORT_VIEW_END(MLNTableView, TableView, YES, "MLNView", "initWithLuaCore:refreshEnable:loadEnable:")

@end
