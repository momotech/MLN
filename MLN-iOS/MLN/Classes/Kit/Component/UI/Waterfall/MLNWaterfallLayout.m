//
//  MLNWaterfallLayout.m
//  
//
//  Created by MoMo on 2018/7/18.
//

#import "MLNWaterfallLayout.h"
#import "MLNInternalWaterfallView.h"
#import "MLNViewExporterMacro.h"
#import "MLNHeader.h"
#import "MLNKitHeader.h"
#import "MLNWaterfallLayoutDelegate.h"

@interface MLNWaterfallLayout ()

@property (nonatomic, assign) NSUInteger columnCount;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGSize myContentSize;

@property (nonatomic, strong) NSMutableDictionary *colunMaxYDic;
@property (strong, nonatomic) NSMutableDictionary *cellLayoutInfo;//保存cell的布局
@property (strong, nonatomic) NSMutableDictionary *headLayoutInfo;//保存头视图的布局

@property (assign, nonatomic) CGFloat startY;   //记录开始的Y
@property (nonatomic, assign) BOOL needRelayout;

@end

@implementation MLNWaterfallLayout

- (instancetype)init
{
    if (self = [super init]) {
        _columnCount = 2;
    }
    return self;
}


- (void)relayoutIfNeed
{
    if (!self.needRelayout) {
        return;
    }
    self.needRelayout = NO;
    [self invalidateLayout];
    [self _in_prepareLayout];
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
    [self _in_prepareLayout];
}


- (void)_in_prepareLayout
{
    [super prepareLayout];
    
    //重新布局需要清空
    [_cellLayoutInfo removeAllObjects];
    [_headLayoutInfo removeAllObjects];
    [_colunMaxYDic removeAllObjects];
    self.startY = 0;
    
    //列数
    MLNKitLuaAssert(_columnCount > 0, @"The spanCount must greater than 0!");
    NSInteger columnCount = _columnCount <= 0? 1 : _columnCount;
    
    // 检查是否实现代理方法
    NSAssert([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)], @"The delegate of Waterfall must implement 'collectionView:layout:referenceSizeForHeaderInSection:' method!");
    NSAssert([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:)], @"The delegate of Waterfall must implement 'collectionView:layout:heightForItemAtIndexPath:' method!");
    NSAssert([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)], @"The delegate of Waterfall must implement 'collectionView:viewForSupplementaryElementOfKind:atIndexPath:' method!");
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - ((columnCount + 1) * self.itemSpacing)) / columnCount;
    //取有多少个section
    NSInteger sectionsCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionsCount; section++) {
        //存储headerView属性
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        CGSize size = CGSizeZero;
        if (section == 0) {
            size = [(id<MLNWaterfallLayoutDelegate>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
            //头视图的高度不为0并且根据代理方法能取到对应的头视图的时候，添加对应头视图的布局对象
            if (size.height >= 0) { //只有header高度大于0情况下，才保存header布局属性
                UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndexPath];
                UIView *headerView = [MLNInternalWaterfallView headerViewInWaterfall:self.collectionView];
                //设置frame
                if (!headerView) {
                    self.startY = self.lineSpacing;
                    attribute.frame = CGRectMake(self.itemSpacing, self.startY, self.collectionView.frame.size.width - 2 * self.itemSpacing, size.height);
                } else {
                    attribute.frame = CGRectMake(0, self.startY, self.collectionView.frame.size.width, size.height);
                }
                //保存布局对象
                self.headLayoutInfo[supplementaryViewIndexPath] = attribute;
                //设置下个布局对象的开始Y值
                self.startY = self.startY + size.height + self.lineSpacing;
            }
        }
        
        //将Section第一排cell的frame的Y值进行设置
        for (int i = 0; section == 0 && i < columnCount; i++) {
            self.colunMaxYDic[@(i)] = @(self.startY);
        }
        
        //计算cell的布局
        //取出section有多少个row
        NSInteger rowsCount = [self.collectionView numberOfItemsInSection:section];
        //分别计算设置每个cell的布局对象
        for (NSInteger row = 0; row < rowsCount; row++) {
            NSIndexPath *cellIndePath =[NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndePath];
            
            //计算当前的cell加到哪一列（瀑布流是加载到最短的一列）
            CGFloat y = CGFloatValueFromNumber(self.colunMaxYDic[@(0)]);
            NSInteger currentRow = 0;
            for (int i = 1; i < self.columnCount; i++) {
                CGFloat tmp = CGFloatValueFromNumber(self.colunMaxYDic[@(i)]);
                if (tmp < y) {
                    y = tmp;
                    currentRow = i;
                }
            }
            //计算x值
            CGFloat x = self.itemSpacing+(currentRow *(itemWidth + self.itemSpacing));
            //根据代理去当前cell的高度  因为当前是采用通过列数计算的宽度，高度根据图片的原始宽高比进行设置的
            //高度
            CGFloat height = [(id<MLNWaterfallLayoutDelegate>)self.collectionView.delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:cellIndePath];
            //设置当前cell布局对象的frame
            attribute.frame = CGRectMake(x, y, itemWidth, height);
            //重新设置当前列的Y值
            y = y + self.lineSpacing + height;
            self.colunMaxYDic[@(currentRow)] = @(y);
            //保留cell的布局对象
            self.cellLayoutInfo[cellIndePath] = attribute;
            
            //当是section的最后一个cell是，取出最后一排cell的底部Y值   设置startY 决定下个视图对象的起始Y值
            if (row == rowsCount -1) {
                CGFloat maxY = CGFloatValueFromNumber(self.colunMaxYDic[@(0)]);
                for (int i = 1; i < self.columnCount; i++) {
                    CGFloat tmp = CGFloatValueFromNumber(self.colunMaxYDic[@(i)]);
                    if ( tmp > maxY) {
                        maxY = tmp;
                    }
                }
                self.startY = maxY - self.lineSpacing;
            }
        }
    }
    self.myContentSize = CGSizeMake(self.collectionView.frame.size.width, self.startY);
}

#pragma mark - collectionView delegate

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    //添加当前屏幕可见的头视图的布局
    [self.headLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    //添加当前屏幕可见的cell的布局
    [self.cellLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    return [allAttributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellLayoutInfo objectForKey:indexPath];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attribute = self.headLayoutInfo[indexPath];
    }
    
    return attribute;
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


- (NSMutableDictionary<NSIndexPath *,UICollectionViewLayoutAttributes *> *)headLayoutInfo
{
    if (!_headLayoutInfo) {
        _headLayoutInfo = [NSMutableDictionary dictionary];
    }
    return _headLayoutInfo;
}

- (NSMutableDictionary *)colunMaxYDic
{
    if (!_colunMaxYDic) {
        _colunMaxYDic = [NSMutableDictionary dictionary];
    }
    return _colunMaxYDic;
}

#pragma mark - Export For Lua
LUA_EXPORT_BEGIN(MLNWaterfallLayout)
LUA_EXPORT_PROPERTY(spanCount, "setColumnCount:", "columnCount", MLNWaterfallLayout)
LUA_EXPORT_PROPERTY(lineSpacing, "setLineSpacing:","lineSpacing", MLNWaterfallLayout)
LUA_EXPORT_PROPERTY(itemSpacing, "setItemSpacing:","itemSpacing", MLNWaterfallLayout)
LUA_EXPORT_END(MLNWaterfallLayout, WaterfallLayout, NO, NULL, NULL)

@end
