//
//  MLNUIViewPager.m
//  MLNUI
//
//  Created by MoMo on 2018/8/31.
//

#import "MLNUIViewPager.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUIBlock.h"
#import "UIView+MLNUILayout.h"
#import "MLNUITabSegmentView.h"
#import "MLNUIViewPagerAdapter.h"
#import "MLNUITabSegmentScrollHandler.h"
#import "MLNUIInnerCollectionView.h"
#import "MLNUIBeforeWaitingTask.h"
#import "UIView+MLNUIKit.h"

#define kMLNUIViewPagerCellReuseId @"kMLNUIViewPagerCellReuseId"

@interface MLNUIViewPager() <UICollectionViewDelegate, MLNUITabSegmentScrollHandlerDelegate>
@property (nonatomic, weak) MLNUIInnerCollectionView *mainView; // 显示图片的collectionView
@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGFloat lastContentOffsetX;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) MLNUIBlock *didEndDeceleratingBlock;
/** 是否自动滚动,默认Yes */
@property (nonatomic,assign) BOOL autoScroll;
@property (nonatomic, assign) BOOL recurrence;
@property (nonatomic, assign) NSUInteger frameInterval;
@property (nonatomic, assign) BOOL showPageControl;
/** 当前分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *currentPageDotColor;
/** 其他分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *pageDotColor;
@property (nonatomic, assign) CGSize pageControlDotSize;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) MLNUIBlock *cellWillAppearCallback;
@property (nonatomic, strong) MLNUIBlock *cellDidDisappearCallback;
@property (nonatomic, strong) MLNUIBlock *cellClickedCallback;
@property (nonatomic, strong) MLNUIBlock *reloadFinishedCallback;
@property (nonatomic, strong) MLNUIBlock *scrollingListerCallback;
@property (nonatomic, strong) MLNUIBlock *selectedCallback;

@property (nonatomic, assign) NSInteger beginIndex;
@property (nonatomic, assign) BOOL scrollEnable;

@property (nonatomic, assign) BOOL outsideCall;

@property (nonatomic, strong) MLNUITabSegmentScrollHandler *viewPagerScrollHandler;

@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;
@property (nonatomic, assign) NSInteger scrollToIndex;
@end

@implementation MLNUIViewPager

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore
{
    if (self = [super initWithMLNUILuaCore:luaCore]){
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)setupMainView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
     _flowLayout = flowLayout;
    MLNUIInnerCollectionView *mainView = [[MLNUIInnerCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.containerView = self;
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView registerClass:[MLNUICollectionViewCell class] forCellWithReuseIdentifier:kMLNUIViewPagerCellReuseId];
    mainView.scrollsToTop = NO;
    mainView.bounces = NO;
    [self addSubview:mainView];
    mainView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        mainView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if (@available(iOS 10.0, *)) {
        mainView.prefetchingEnabled = NO;
    }
    _mainView = mainView;
}

- (void)initialization
{
    _scrollEnable = YES;
    _autoScroll = NO;
    _recurrence = NO;
    _frameInterval = 2;
    _aheadLoad = NO;
    _showPageControl = YES;
    _pageControlDotSize = CGSizeMake(10, 10);
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:0.1];
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self invalidateTimer];
    } else {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)mlnui_user_data_dealloc
{
    // 去除强引用
    MLNUI_Lua_UserData_Release(self.adapter);
    [super mlnui_user_data_dealloc];
}

- (void)dealloc
{
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}

#pragma mark - setter
- (void)setAdapter:(id<UICollectionViewDataSource,MLNUICycleScrollViewDelegate>)adapter
{
    MLNUICheckTypeAndNilValue(adapter, @"ViewPagerAdapter", [MLNUIViewPagerAdapter class])
    if (_adapter != adapter) {
        // 去除强引用
          MLNUI_Lua_UserData_Release(_adapter);
          // 添加强引用
          MLNUI_Lua_UserData_Retain_With_Index(2, adapter);
        _adapter = adapter;
        _mainView.delegate = self;
        adapter.viewPager = self;
        adapter.targetCollectionView = self.mainView;
        if (self.superview) {
            [self mlnui_pushLazyTask:self.lazyTask];
        }
    }
}

- (void)setRecurrence:(BOOL)recurrence
{
    if (_tabSegmentView && recurrence) {
        MLNUIKitLuaAssert(NO, @"Do not set loop scrolling when TabSegmentView was bound");
        recurrence = NO;
    }
    if (_recurrence == recurrence) {
        return;
    }
    _recurrence = recurrence;
    if (self.superview) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    [self invalidateTimer];
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    [self settingPageController];
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    self.pageControl.pageIndicatorTintColor = pageDotColor;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    self.pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
}

- (void)setupTimer
{
    [self invalidateTimer];
    [self timer];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (NSInteger)updateTotalItemCount:(NSInteger)cellCount
{
    _totalItemsCount = self.recurrence? cellCount * 6 : cellCount;
    return _totalItemsCount;
}

#pragma mark - Private Func
- (NSInteger)correctCurrentIndex
{
    NSInteger width = self.mainView.frame.size.width ?: 1;
    NSInteger cellCount = self.adapter.cellCounts ?: 1;
    return (NSInteger)(self.mainView.contentOffset.x / width) % cellCount;
}

- (void)setupMainViewFrame
{
    CGRect newRect = UIEdgeInsetsInsetRect(self.bounds, self.padding);
    if (CGRectEqualToRect(newRect, self.mainView.frame)) {
        return;
    }
    self.flowLayout.itemSize = newRect.size;
    
    id delegate = self.mainView.delegate;
    self.mainView.delegate = nil;
    self.mainView.frame = newRect;
    self.mainView.delegate = delegate;
}

- (void)didChangedPage
{
    if (_selectedCallback) {
        [_selectedCallback addIntegerArgument:[self correctCurrentIndex] + 1];
        [_selectedCallback callIfCan];
    }
}

- (void)settingPageController
{
    self.pageControl.hidden = !_showPageControl;
    if (!_showPageControl) {
        return;
    }
    NSInteger pages = _showPageControl?self.adapter.cellCounts:0;
    CGRect newRect = self.mainView.frame;
    CGSize size = CGSizeMake(self.adapter.cellCounts * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    CGFloat x = newRect.origin.x +  (newRect.size.width - size.width) * 0.5;
    CGFloat y = newRect.origin.y + newRect.size.height - size.height - 10;
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    if (!CGRectEqualToRect(self.pageControl.frame, pageControlFrame)) {
        self.pageControl.frame = pageControlFrame;
    }
    self.pageControl.numberOfPages = pages;
}

- (void)automaticScroll
{
    if (0 == _totalItemsCount) return;
    int currentIndex = [self currentIndex];
    int targetIndex = (currentIndex + 1) % _totalItemsCount;
    [self scrollToIndex:targetIndex animated:YES];
    if (_tabSegmentView) {
        [_tabSegmentView setCurrentLabelIndex:targetIndex animated:YES];
    }
}

- (int)currentIndex
{
    CGRect frame = self.frame;
    if (frame.size.width == 0 || frame.size.height == 0) return 0;
    int index = (_mainView.contentOffset.x + self.flowLayout.itemSize.width * 0.5) / self.flowLayout.itemSize.width;
    return MAX(0, index);
}

- (void)scrollToIndex:(int)targetIndex animated:(BOOL)animated
{
    if (targetIndex >= [self.mainView numberOfItemsInSection:0] || targetIndex<0 || isnan(targetIndex)) return;
    _scrollToIndex = targetIndex;
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.adapter.cellCounts;
}

- (void)setupWithCurrentStatus
{
    NSUInteger cellCount = self.adapter.cellCounts;
    //    当cell数量大于1时，检查是否需要循环滚动
    if (cellCount > 1) { // 由于 !=1 包含count == 0等情况
        [self setAutoScroll:self.autoScroll];
    } else {
        [self invalidateTimer];
    }
    _mainView.scrollEnabled = cellCount != 1 && _scrollEnable;
    //    根据当前页数，处理指示器数量
    [self settingPageController];
    if (_missionIndex > 0) {
        [self luaui_scrollToPage:_missionIndex aniamted:_missionAnimated];
        _missionIndex = 0;
        _missionAnimated = NO;
    }
    //    开启无限滚动时，进行页码矫正操作
    [self scrollToCorrectPage];
    //    存在监听刷新结束的操作时，触发回调，由于该触发只有一次，所以触发后置空
    if (_reloadFinishedCallback) {
        [_reloadFinishedCallback callIfCan];
        _reloadFinishedCallback = nil;
    }
}

#pragma mark - Export For Lua

- (void)luaui_cellWillAppearCallback:(MLNUIBlock *)callback
{
    self.cellWillAppearCallback = callback;
}

- (void)luaui_cellDidDisappearCallback:(MLNUIBlock *)callback
{
    self.cellDidDisappearCallback = callback;
}

- (void)luaui_cellClickedCallback:(MLNUIBlock *)callback
{
    self.cellClickedCallback = callback;
}

- (void)scrollToPage:(NSUInteger)index aniamted:(BOOL)animated {
    //外部调用，不触发TabSegment的回调，内部调用需要触发
    _outsideCall = YES;
    [self luaui_scrollToPage:index + 1 aniamted:animated];
}

- (void)luaui_scrollToPage:(NSUInteger)index aniamted:(BOOL)animated
{
    if (0 == _totalItemsCount)
    {
        _missionIndex = index;
        _missionAnimated = animated;
        _outsideCall = NO;
        return;
    }
    if (self.tabSegmentView && !_outsideCall) {
        [self.tabSegmentView setCurrentLabelIndex:index - 1 animated:animated];
    }
    NSUInteger opertaionIndex = index - 1;
    MLNUIKitLuaAssert(opertaionIndex >= 0 && opertaionIndex < _totalItemsCount, @"Page index out of range!");
    if (opertaionIndex >= self.adapter.cellCounts || isnan(opertaionIndex)) return;
    if (self.autoScroll) {
        [self invalidateTimer];
    }
    int curItem = self.mainView.contentOffset.x/self.mainView.frame.size.width;
    int curIndex = [self pageControlIndexWithCurrentCellIndex:curItem];
    int offsetIndex = (int)opertaionIndex - curIndex;
    [self scrollToIndex:(int)(curItem + offsetIndex) animated:animated];
    if (self.autoScroll) {
        [self setupTimer];
    } else if (_aheadLoad) {
        [self aheadLoadPage:(int)(curItem + offsetIndex) + 1];
    }
    _outsideCall = NO;
}

- (void)aheadLoadPage:(NSInteger)index {
    if (index < 0 || index >= [self.adapter collectionView:self.mainView numberOfItemsInSection:0] ) {
        return;
    }
    
    [self.adapter collectionView:self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (void)luaui_reloadData
{
    _totalItemsCount = 0;
    if (self.superview) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)luaui_reloadFinished:(MLNUIBlock *)block
{
    self.reloadFinishedCallback = block;
    if (self.superview) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (NSUInteger)luaui_currentPage
{
    int curItem = self.mainView.contentOffset.x/self.mainView.frame.size.width;
    int curIndex = [self pageControlIndexWithCurrentCellIndex:curItem];
    int result = curIndex + 1;
    return  result;
}

- (void)luaui_setPageSelectedListener:(MLNUIBlock *)callback
{
    self.selectedCallback = callback;
}

#pragma mark - getter

- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself setupMainViewFrame];
            if (sself.adapter.targetCollectionView.dataSource != sself.adapter) {
                sself.adapter.targetCollectionView.dataSource = sself.adapter;
            }
            [sself.adapter.targetCollectionView reloadData];
            [sself.adapter.targetCollectionView performBatchUpdates:^{
            } completion:^(BOOL finished) {
                [sself setupWithCurrentStatus];
            }];
        }];
    }
    return _lazyTask;
}

- (NSTimer *)timer
{
    if (!_timer){
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.frameInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
        _timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.numberOfPages = self.adapter.cellCounts;
        pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
        pageControl.pageIndicatorTintColor = self.pageDotColor;
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}


- (void)scrollToCorrectPage
{
    if (self.recurrence && self.adapter && self.totalItemsCount){
        NSUInteger curIndex = (_mainView.contentOffset.x)/_mainView.frame.size.width;
        if (curIndex == self.totalItemsCount-1 || curIndex == 0){
            BOOL isRight = self.lastContentOffsetX < self.mainView.contentOffset.x;
            CGFloat offsetX = isRight ? - self.totalItemsCount * 0.5 : self.totalItemsCount * 0.5;
            NSUInteger subNumber = curIndex + offsetX;
            NSUInteger finalIndex = [self pageControlIndexWithCurrentCellIndex:subNumber] + self.totalItemsCount * 0.5;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:finalIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}

#pragma mark - MLNUITabSegmentViewDelegate
- (BOOL)segmentView:(MLNUITabSegmentView *)segmentView shouldScrollToIndex:(NSInteger)toIndex
{
    return toIndex < _adapter.cellCounts;
}

- (NSInteger)segmentView:(MLNUITabSegmentView *)segmentView correctIndexWithToIndex:(NSInteger)toIndex
{
    return toIndex < 0 ? 0 : (toIndex >= _adapter.cellCounts ? _adapter.cellCounts - 1 : toIndex);
}

#pragma mark - MLNUITabSegmentScrollHandlerDelegate

- (void)scrollDidEndDragging
{
}

- (void)scrollDidFinished
{
}

- (void)scrollDidStart
{
}

- (void)scrollWithOldIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    if (_scrollingListerCallback) {
        //        场景列举，拖拽时，当前页为开始页
        NSUInteger trueFromIndex = 0;
        NSUInteger trueToIndex = 0;
        CGFloat trueProgress = 0;
        //   计算百分比的算法在完整切页后会出现fromIndex=toIndex的现象，特别是在第一页与最后一页时，需要修正错误的index值
        if (fromIndex >= toIndex) {
            return;
        }
        if (self.beginIndex == fromIndex) {
            trueFromIndex = fromIndex;
            trueToIndex = toIndex;
        } else {
            trueFromIndex = toIndex;
            trueToIndex = fromIndex;
        }
        trueProgress = (trueFromIndex == fromIndex) ? progress : 1.0 - progress;
        [_scrollingListerCallback addFloatArgument:trueProgress];
        [_scrollingListerCallback addIntegerArgument:trueFromIndex + 1];
        [_scrollingListerCallback addIntegerArgument:trueToIndex + 1];
        [_scrollingListerCallback callIfCan];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.beginIndex = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
    _scrollToIndex = -1;
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_segmentViewHandler scrollViewWillBeginDragging:scrollView];
    }
    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_viewPagerScrollHandler scrollViewWillBeginDragging:scrollView];
    }
    self.lastContentOffsetX = scrollView.contentOffset.x;
    if (!self.autoScroll) return;
    [self invalidateTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_segmentViewHandler scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_viewPagerScrollHandler scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (!self.autoScroll) return;
    [self setupTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_segmentViewHandler scrollViewDidScroll:scrollView];
    }
    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_viewPagerScrollHandler scrollViewDidScroll:scrollView];
    }
    if (!self.totalItemsCount) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    UIPageControl *pageControl = (UIPageControl *)_pageControl;
    pageControl.currentPage = indexOnPageControl;
    if (_scrollToIndex == itemIndex && (int)floor(scrollView.contentOffset.x) % (int)floor(scrollView.frame.size.width ?: 1) == 0) {
        [self didChangedPage];
        _scrollToIndex = -1;
    }
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage =  [self correctCurrentIndex];
    if (currentPage != self.beginIndex) {
        [self didChangedPage];
    }
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        if (currentPage < [self.adapter collectionView:(UICollectionView*)scrollView numberOfItemsInSection:0] - 1 && currentPage != self.beginIndex && _aheadLoad ) {
            [self aheadLoadPage:currentPage + 1];
            [self aheadLoadPage:currentPage - 1];
        }
    }
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_segmentViewHandler scrollViewDidEndDecelerating:scrollView];
    }
    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_viewPagerScrollHandler scrollViewDidEndDecelerating:scrollView];
    }
    [self scrollToCorrectPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_segmentViewHandler scrollViewDidEndScrollingAnimation:scrollView];
    }
    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_viewPagerScrollHandler scrollViewDidEndScrollingAnimation:scrollView];
    }
    if (!self.totalItemsCount) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex]+1;
    [self.didEndDeceleratingBlock addIntArgument:indexOnPageControl];
    [self.didEndDeceleratingBlock callIfCan];
    
    [self scrollToCorrectPage];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (self.cellWillAppearCallback) {
        MLNUIKitLuaAssert([cell isKindOfClass:[MLNUICollectionViewCell class]], @"Unkown type of cell");
        MLNUICollectionViewCell *cell_t = (MLNUICollectionViewCell *)cell;
        [self.cellWillAppearCallback addLuaTableArgument:[cell_t getLuaTable]];
        [self.cellWillAppearCallback addIntArgument:(int)indexPath.item+1];
        [self.cellWillAppearCallback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDidDisappearCallback) {
        MLNUIKitLuaAssert([cell isKindOfClass:[MLNUICollectionViewCell class]], @"Unknow type of cell!");
        MLNUICollectionViewCell *cell_t = (MLNUICollectionViewCell *)cell;
        [self.cellDidDisappearCallback addLuaTableArgument:[cell_t getLuaTable]];
        [self.cellDidDisappearCallback addIntArgument:(int)indexPath.item+1];
        [self.cellDidDisappearCallback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellClickedCallback) {
        int curItem = self.mainView.contentOffset.x/self.mainView.frame.size.width;
        int curIdx = [self pageControlIndexWithCurrentCellIndex:curItem] + 1;
        [self.cellClickedCallback addIntArgument:curIdx];
        [self.cellClickedCallback callIfCan];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger itemIndex = targetContentOffset->x/_mainView.frame.size.width;
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex]+1;
    [self.didEndDeceleratingBlock addIntArgument:indexOnPageControl];
    [self.didEndDeceleratingBlock callIfCan];
}


#pragma mark - Override

- (CGSize)mlnui_sizeThatFits:(CGSize)size {
    return size;
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

- (void)mlnui_layoutDidChange {
    [super mlnui_layoutDidChange];
    [self setupMainViewFrame];
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

- (void)luaui_setLuaScrollEnable:(BOOL)enable
{
    _scrollEnable  = enable;
    self.mainView.scrollEnabled = enable;
}

- (void)luaui_setPreRenderCount:(NSInteger)count
{
    
}

- (void)luaui_setTabScrollingListener:(MLNUIBlock *)block
{
    _scrollingListerCallback = block;
    if (!_viewPagerScrollHandler && block) {
        _viewPagerScrollHandler = [[MLNUITabSegmentScrollHandler alloc] init];
        _viewPagerScrollHandler.delegate = self;
    } else if(!block) {
        _viewPagerScrollHandler  = nil;
    }
}

- (void)luaui_setPadding:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    self.padding = UIEdgeInsetsMake(top, left, bottom, right);
    if (self.superview) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)luaui_setPageControlDotSize:(CGSize)dotSize
{
    self.pageControlDotSize = dotSize;
    if (self.superview) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)dealloc4Lua
{
    [self invalidateTimer];
}

LUAUI_EXPORT_VIEW_BEGIN(MLNUIViewPager)
LUAUI_EXPORT_VIEW_PROPERTY(adapter, "setAdapter:","adapter", MLNUIViewPager)
LUAUI_EXPORT_VIEW_PROPERTY(autoScroll, "setAutoScroll:", "autoScroll", MLNUIViewPager)
LUAUI_EXPORT_VIEW_PROPERTY(recurrence, "setRecurrence:", "recurrence", MLNUIViewPager)
LUAUI_EXPORT_VIEW_PROPERTY(frameInterval, "setFrameInterval:", "frameInterval", MLNUIViewPager)
LUAUI_EXPORT_VIEW_PROPERTY(showIndicator, "setShowPageControl:", "showPageControl", MLNUIViewPager)
LUAUI_EXPORT_VIEW_PROPERTY(aheadLoad, "setAheadLoad:", "aheadLoad", MLNUIViewPager)
LUAUI_EXPORT_METHOD(endDragging, "setDidEndDeceleratingBlock:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(reloadData, "luaui_reloadData", MLNUIViewPager)
LUAUI_EXPORT_METHOD(reloadDataFinished, "luaui_reloadFinished:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(scrollToPage, "luaui_scrollToPage:aniamted:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(currentPageColor, "setCurrentPageDotColor:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(pageDotColor, "setPageDotColor:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(pageControlDotSize, "setPageControlDotSize:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(currentPage, "luaui_currentPage", MLNUIViewPager)
LUAUI_EXPORT_METHOD(setPreRenderCount, "luaui_setPreRenderCount:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(cellWillAppear, "luaui_cellWillAppearCallback:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(cellDidDisappear, "luaui_cellDidDisappearCallback:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(setPageClickListener, "luaui_cellClickedCallback:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(setScrollEnable, "luaui_setLuaScrollEnable:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(setTabScrollingListener, "luaui_setTabScrollingListener:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(padding, "luaui_setPadding:right:bottom:left:", MLNUIViewPager)
LUAUI_EXPORT_METHOD(onChangeSelected, "luaui_setPageSelectedListener:", MLNUIViewPager)
LUAUI_EXPORT_VIEW_END(MLNUIViewPager, ViewPager, YES, "MLNUIView", NULL)

@end
