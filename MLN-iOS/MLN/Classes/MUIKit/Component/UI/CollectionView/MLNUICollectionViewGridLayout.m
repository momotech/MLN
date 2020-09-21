//
//  MLNUICollectionViewGridLayout.m
//
//
//  Created by MoMo on 2018/12/14.
//

#import "MLNUICollectionViewGridLayout.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUICollectionView.h"

#define MLNUI_FLOAT_TOLERANT 0.1f

@interface MLNUICollectionViewGridLayout()
{
    MLNUIScrollDirection _scrollDirection;
}

@property (nonatomic, assign) NSUInteger spanCount;
@property (nonatomic, assign) UIEdgeInsets layoutInset;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGSize myContentSize;
@property (nonatomic, strong) NSMutableDictionary *cellLayoutInfo;

// 纵向滚动
@property (nonatomic, assign) CGFloat layoutHeight;
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, assign) CGFloat maxHeight;

// 横向滚动
@property (nonatomic, assign) CGFloat layoutWidth;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxWidth;

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger col;

@property (nonatomic, assign) BOOL needRelayout;

@end

@implementation MLNUICollectionViewGridLayout

- (instancetype)init
{
    if (self = [super init]) {
        _spanCount = 1;
    }
    return self;
}

- (void)luaui_setLineSpacing:(CGFloat)lineSpacing
{
    self.lineSpacing = lineSpacing;
}

- (CGFloat)luaui_lineSpacing
{
    return self.lineSpacing;
}

- (void)luaui_setItemSpacing:(CGFloat)itemSpacing
{
    self.itemSpacing = itemSpacing;
}

- (CGFloat)luaui_itemSpacing
{
    return self.itemSpacing;
}

- (void)luaui_setlayoutInset:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom  right:(CGFloat)right
{
    self.layoutInset = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)luaui_setSpanCount:(NSUInteger)spanCount
{
    self.spanCount = spanCount;
}

- (NSInteger)luaui_spanCount
{
    return self.spanCount;
}

#pragma mark - private method

- (void)relayoutIfNeed
{
    if (self.needRelayout) {
        self.needRelayout = NO;
        __in_prepareLayout(self);
    }
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 过滤无效布局
    CGSize size = self.collectionView.frame.size;
    if (size.width <= 0 || size.height <= 0) {
        self.needRelayout = YES;
        return;
    }
    __in_prepareLayout(self);
}

static MLNUI_FORCE_INLINE void __in_prepareLayout(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef) {
    // 0.0 重置布局信息
    [selfRef resetLayoutValues];
    
    // 1.0 计算单个格子中可容纳最大cell尺寸
    [selfRef initLayoutLength];
    
    // 2.0 计算item所在的格子数
    NSInteger section = [selfRef.collectionView numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        NSInteger itemCount = [selfRef.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < itemCount; j++) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:j inSection:i];
            layoutItemForIndexPath(selfRef, cellIndexPath);
        }
    }
    
    // 3.0 更新contentSize
    updateContentSize(selfRef);
}

static MLNUI_FORCE_INLINE void updateContentSize(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef) {
    if (selfRef.isScrollHorizontal) {
        selfRef.myContentSize = CGSizeMake(selfRef->_maxX + selfRef->_maxWidth + selfRef.layoutInset.left + selfRef.layoutInset.right, selfRef.collectionView.frame.size.height);
    } else {
        selfRef.myContentSize = CGSizeMake(selfRef.collectionView.frame.size.width, selfRef->_maxY + selfRef->_maxHeight + selfRef.layoutInset.top + selfRef.layoutInset.bottom);
    }
}

static MLNUI_FORCE_INLINE void layoutItemForIndexPath(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef, const __unsafe_unretained NSIndexPath *indexPath)
{
    if ([selfRef isScrollHorizontal]) {
        layoutItemVerticallyForIndexPath(selfRef, indexPath);
    } else {
        layoutItemHorizontallyForIndexPath(selfRef, indexPath);
    }
}

static MLNUI_FORCE_INLINE void layoutItemHorizontallyForIndexPath(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef, const __unsafe_unretained NSIndexPath *indexPath)
{
    MLNUILuaAssert(selfRef.mlnui_luaCore, [selfRef.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)], @"It must implment sizeForCell method");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    CGSize cellSize = [(id<MLNUICollectionViewGridLayoutDelegate>)selfRef.collectionView.delegate collectionView:selfRef.collectionView layout:selfRef sizeForItemAtIndexPath:indexPath];
#pragma clang diagnostic pop
    MLNUILuaAssert(selfRef.mlnui_luaCore, cellSize.width <= selfRef.collectionView.frame.size.width - selfRef.layoutInset.left - selfRef.layoutInset.right, @"The sum of cellWidth，leftInset，rightInset should not bigger than the width of collectionView");
    
    // 2.1 记录当前行数、列数
    NSInteger currentCol = [selfRef col];
    NSInteger currentRow = [selfRef row];
    
    // 2.2 计算该Item占用格子个数
    NSUInteger gridSpanCurrentRow = getSpanSizeWithItemSize(selfRef, cellSize, [selfRef layoutWidth], [selfRef itemSpacing]);
    
    // 2.3 如果当前行放不下该cell(该cell占满spanCount 或者 当前行剩余格子数放不下该cell)
    if ([selfRef col] != 0 && (gridSpanCurrentRow == [selfRef spanCount] || !currentIndexGridIsEnoughForCellSize(selfRef, currentCol, cellSize, [selfRef itemSpacing]))) {
        
        // 2.3.1 换行更新maxY
        selfRef->_maxY = selfRef->_maxY + selfRef->_maxHeight + selfRef.lineSpacing;
        
        // 重置当前行最大高度为0，行数+1
        selfRef->_maxHeight = 0.0;
        selfRef->_col = 0;
        selfRef->_row = selfRef->_row + 1;
        
        currentCol = selfRef->_col;
        currentRow = selfRef->_row;
    }
    
    // 2.3.2 更新col
    selfRef->_col = selfRef->_col + gridSpanCurrentRow;
    
    // 2.4 计算该cellframe
    CGFloat cellX = 0.0;
    if (currentCol == 0) {
        cellX = selfRef.layoutInset.left;
    } else {
        cellX = selfRef.layoutInset.left + ([selfRef itemSpacing] + [selfRef layoutWidth]) * currentCol;
    }
    CGFloat cellY = 0.0;
    if (currentRow == 0) {
        cellY = selfRef.layoutInset.top;
    } else {
        cellY = selfRef.layoutInset.top + [selfRef maxY];
    }
    CGFloat cellW = cellSize.width;
    CGFloat cellH = cellSize.height;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
#pragma clang diagnostic pop
    CGRect frame = CGRectMake(cellX, cellY, cellW, cellH);
    attribute.frame = frame;
    
    // 2.6 更新当前行的maxHeight
    selfRef->_maxHeight = MAX(selfRef->_maxHeight, cellH);
    selfRef.cellLayoutInfo[indexPath] = attribute;
}


static MLNUI_FORCE_INLINE void layoutItemVerticallyForIndexPath(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef, const __unsafe_unretained NSIndexPath *indexPath)
{
    MLNUILuaAssert(selfRef.mlnui_luaCore, [selfRef.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)], @"It must implment sizeForCell method");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    CGSize cellSize = [(id<MLNUICollectionViewGridLayoutDelegate>)selfRef.collectionView.delegate collectionView:selfRef.collectionView layout:selfRef sizeForItemAtIndexPath:indexPath];
#pragma clang diagnostic pop
    MLNUILuaAssert(selfRef.mlnui_luaCore, cellSize.height <= CGRectGetHeight(selfRef.collectionView.frame) - selfRef.layoutInset.top - selfRef.layoutInset.bottom + MLNUI_FLOAT_TOLERANT, @"The sum of cellHeight，topInset，bottomInset should not bigger than the height of collectionView");
    
    // 2.1 记录当前行数、列数
    NSInteger currentCol = selfRef->_col;
    NSInteger currentRow = selfRef->_row;
    
    // 2.2 计算该Item占用格子个数
    NSUInteger gridSpanCurrentCol = getSpanSizeWithItemSize(selfRef, cellSize, [selfRef layoutHeight], [selfRef lineSpacing]);
    
    // 2.3 如果当前行放不下该cell(该cell占满spanCount 或者 当前行剩余格子数放不下该cell)
    if (selfRef->_row != 0 && (gridSpanCurrentCol == selfRef->_spanCount || !currentIndexGridIsEnoughForCellSize(selfRef, currentRow, cellSize, [selfRef lineSpacing]))) {
        
        // 2.3.1 换行更新maxX
        selfRef->_maxX = selfRef->_maxX + selfRef->_maxWidth + selfRef.itemSpacing;
        
        // 重置当前行最大宽度为0，列数+1
        selfRef->_maxWidth = 0.0;
        selfRef->_col = selfRef->_col + 1;
        selfRef->_row = 0;
        
        currentCol = selfRef->_col;
        currentRow = selfRef->_row;
    }
    
    // 2.3.2 更新row
    selfRef->_row = selfRef->_row + gridSpanCurrentCol;
    
    // 2.4 计算该cellframe
    CGFloat cellX = 0.0;
    if (currentCol == 0) {
        cellX = selfRef.layoutInset.left;
    } else {
        cellX = selfRef.layoutInset.left + selfRef->_maxX;
    }
    CGFloat cellY = 0.0;
    if (currentRow == 0) {
        cellY = selfRef.layoutInset.top;
    } else {
        cellY = selfRef.layoutInset.top + (selfRef->_lineSpacing + selfRef->_layoutHeight) * currentRow;;
    }
    CGFloat cellW = cellSize.width;
    CGFloat cellH = cellSize.height;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
#pragma clang diagnostic pop
    CGRect frame = CGRectMake(cellX, cellY, cellW, cellH);
    attribute.frame = frame;
    
    // 2.6 更新当前行的maxHeight
    selfRef->_maxWidth = MAX(selfRef->_maxWidth, cellW);
    selfRef.cellLayoutInfo[indexPath] = attribute;
}

static MLNUI_FORCE_INLINE long getSpanSizeWithItemSize(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef, CGSize size, CGFloat layoutLength, CGFloat spacing)
{
    CGFloat itemLength = selfRef.isScrollHorizontal? size.height : size.width;
    
    NSInteger spanSize = 1;
    if (itemLength <= layoutLength) {
        return spanSize;
    }
    
    while (spanSize < selfRef->_spanCount ) {
        if (itemLength <= layoutLength * spanSize + spacing * (spanSize - 1)) {
            break;
        }
        spanSize ++;
    }
    return spanSize;
}

static MLNUI_FORCE_INLINE bool currentIndexGridIsEnoughForCellSize(const __unsafe_unretained MLNUICollectionViewGridLayout *selfRef, NSUInteger currentIndex, CGSize cellSize, CGFloat spacing)
{
    if (currentIndex == selfRef->_spanCount) {
        return NO;
    }
    
    CGFloat itemLength = selfRef.isScrollHorizontal? cellSize.height : cellSize.width;
    CGFloat layoutLength = selfRef.isScrollHorizontal? selfRef->_layoutHeight : selfRef->_layoutWidth;
    
    BOOL isEnough = NO;
    if (itemLength <= (selfRef->_spanCount - currentIndex) * layoutLength + (selfRef->_spanCount - currentIndex - 1) *  spacing) {
        isEnough = YES;
    }
    
    return isEnough;
}

- (void)resetLayoutValues
{
    [self.cellLayoutInfo removeAllObjects];
    
    // 重置初始值
    _row = 0;
    _col = 0;
    
    // 纵向滚动
    _maxY = 0.0;
    _maxHeight = 0.0;
    
    // 横向滚动
    _maxX = 0.0;
    _maxWidth = 0.0;
}

#pragma mark - Layout Length
- (void)initLayoutLength
{
    MLNUIKitLuaAssert(_spanCount > 0, @"The spanCount must greater than 0!");
    if (self.isScrollHorizontal) {
        [self initHorizontalLayoutHeight];
    } else {
        [self initVerticalLayoutWidth];
    }
}

- (void)initVerticalLayoutWidth
{
    _layoutWidth = (self.collectionView.frame.size.width - self.layoutInset.left - self.layoutInset.right - self.itemSpacing * (_spanCount - 1)) / _spanCount;
}

- (void)initHorizontalLayoutHeight
{
    _layoutHeight = (self.collectionView.frame.size.height - self.layoutInset.top - self.layoutInset.bottom - self.lineSpacing * (_spanCount - 1)) / _spanCount;
}


#pragma mark -

- (void)setScrollDirection:(MLNUIScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    [self invalidateLayout];
}

- (MLNUIScrollDirection)scrollDirection
{
    return _scrollDirection;
}

- (BOOL)isScrollHorizontal
{
    return self.scrollDirection == MLNUIScrollDirectionHorizontal;
}

#pragma mark - collectionView delegate

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attribute in self.cellLayoutInfo.allValues) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }
    
    return [allAttributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellLayoutInfo objectForKey:indexPath];
}

- (CGSize)collectionViewContentSize
{
    return self.myContentSize;
}

- (NSMutableDictionary *)cellLayoutInfo
{
    if (!_cellLayoutInfo) {
        _cellLayoutInfo = [NSMutableDictionary  dictionary];
    }
    return _cellLayoutInfo;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_BEGIN(MLNUICollectionViewGridLayout)
LUAUI_EXPORT_PROPERTY(lineSpacing, "luaui_setLineSpacing:","luaui_lineSpacing", MLNUICollectionViewGridLayout)
LUAUI_EXPORT_PROPERTY(itemSpacing, "luaui_setItemSpacing:","luaui_itemSpacing", MLNUICollectionViewGridLayout)
LUAUI_EXPORT_PROPERTY(spanCount, "luaui_setSpanCount:","luaui_spanCount", MLNUICollectionViewGridLayout)
LUAUI_EXPORT_METHOD(layoutInset, "luaui_setlayoutInset:left:bottom:right:", MLNUICollectionViewGridLayout)
LUAUI_EXPORT_END(MLNUICollectionViewGridLayout, CollectionLayout, NO, NULL, NULL)

@end
