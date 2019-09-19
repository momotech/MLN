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
    __in_prepareLayout(self);
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

static MLN_FORCE_INLINE void __in_prepareLayout(MLNWaterfallLayout *selfRef) {
    //重新布局需要清空
    [selfRef.cellLayoutInfo removeAllObjects];
    [selfRef.headLayoutInfo removeAllObjects];
    [selfRef.colunMaxYDic removeAllObjects];
    selfRef.startY = 0;
    
    //    宽度
    CGFloat itemWidth = (selfRef.collectionView.frame.size.width - ((selfRef.columnCount + 1) * selfRef.itemSpacing)) / selfRef.columnCount;
    //取有多少个section
    NSInteger sectionsCount = [selfRef.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionsCount; section++) {
        //存储headerView属性
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        CGSize size = CGSizeZero;
        if (section == 0 && [selfRef.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            size = [(id<MLNWaterfallLayoutDelegate>)selfRef.collectionView.delegate collectionView:selfRef.collectionView layout:selfRef referenceSizeForHeaderInSection:section];
        }
        //头视图的高度不为0并且根据代理方法能取到对应的头视图的时候，添加对应头视图的布局对象
        if ([selfRef.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)] && (size.height - 0.001) > 0) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndexPath];
            
            UIView *headerView = [MLNInternalWaterfallView headerViewInWaterfall:selfRef.collectionView];
            //设置frame
            if (!headerView) {
                selfRef.startY = selfRef.lineSpacing;
                attribute.frame = CGRectMake(selfRef.itemSpacing, selfRef.startY, selfRef.collectionView.frame.size.width - 2 * selfRef.itemSpacing, size.height);
            } else {
                attribute.frame = CGRectMake(0, selfRef.startY, selfRef.collectionView.frame.size.width, size.height);
            }
            
            //保存布局对象
            selfRef.headLayoutInfo[supplementaryViewIndexPath] = attribute;
            //设置下个布局对象的开始Y值
            selfRef.startY = selfRef.startY + size.height + selfRef.lineSpacing;
        }
        
        //将Section第一排cell的frame的Y值进行设置
        for (int i = 0; section == 0 && i < selfRef.columnCount; i++) {
            selfRef.colunMaxYDic[@(i)] = @(selfRef.startY);
        }
        //计算cell的布局
        //取出section有多少个row
        NSInteger rowsCount = [selfRef.collectionView numberOfItemsInSection:section];
        //分别计算设置每个cell的布局对象
        for (NSInteger row = 0; row < rowsCount; row++) {
            NSIndexPath *cellIndePath =[NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndePath];
            
            //计算当前的cell加到哪一列（瀑布流是加载到最短的一列）
            CGFloat y = CGFloatValueFromNumber(selfRef.colunMaxYDic[@(0)]);
            NSInteger currentRow = 0;
            for (int i = 1; i < selfRef.columnCount; i++) {
                CGFloat tmp = CGFloatValueFromNumber(selfRef.colunMaxYDic[@(i)]);
                if (tmp < y) {
                    y = tmp;
                    currentRow = i;
                }
            }
            //计算x值
            CGFloat x = selfRef.itemSpacing+(currentRow *(itemWidth + selfRef.itemSpacing));
            //根据代理去当前cell的高度  因为当前是采用通过列数计算的宽度，高度根据图片的原始宽高比进行设置的
            //    高度
            CGFloat height = 0;
            
            if ([selfRef.collectionView.delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:)]) {
                height = [(id<MLNWaterfallLayoutDelegate>)selfRef.collectionView.delegate collectionView:selfRef.collectionView layout:selfRef heightForItemAtIndexPath:cellIndePath];
            }
            
            //设置当前cell布局对象的frame
            attribute.frame = CGRectMake(x, y, itemWidth, height);
            //重新设置当前列的Y值
            y = y + selfRef.lineSpacing + height;
            selfRef.colunMaxYDic[@(currentRow)] = @(y);
            //保留cell的布局对象
            selfRef.cellLayoutInfo[cellIndePath] = attribute;
            
            //当是section的最后一个cell是，取出最后一排cell的底部Y值   设置startY 决定下个视图对象的起始Y值
            if (row == rowsCount -1) {
                CGFloat maxY = CGFloatValueFromNumber(selfRef.colunMaxYDic[@(0)]);
                for (int i = 1; i < selfRef.columnCount; i++) {
                    CGFloat tmp = CGFloatValueFromNumber(selfRef.colunMaxYDic[@(i)]);
                    if ( tmp > maxY) {
                        maxY = tmp;
                    }
                }
                selfRef.startY = maxY - selfRef.lineSpacing;
            }
        }
    }
    selfRef.myContentSize = CGSizeMake(selfRef.collectionView.frame.size.width, selfRef.startY);
}

- (void)invalidateLayout {
    _cellLayoutInfo = nil;
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
