//
//  MLNUIAdapterCachesManager.m
//  
//
//  Created by MoMo on 2019/3/18.
//

#import "MLNUIAdapterCachesManager.h"

@interface MLNUIAdapterCachesManager ()

@property (nonatomic, assign) NSInteger sectionCount;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *rowCount;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSString *> *reuseIdentifiers;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, id> *layoutInfos;

@end
@implementation MLNUIAdapterCachesManager

static NSNumber *kNumberZero = nil;
- (instancetype)init
{
    self = [super init];
    if (self) {
        // caches
        _rowCount = [NSMutableArray array];
        _reuseIdentifiers = [NSMutableDictionary dictionary];
        _layoutInfos = [NSMutableDictionary dictionary];
        if (kNumberZero == nil) {
            kNumberZero = @(0);
        }
    }
    return self;
}

- (NSInteger)sectionCount
{
    return _sectionCount;
}

- (NSInteger)rowCountInSection:(NSInteger)section
{
    if (section >= self.rowCount.count) {
        return 0;
    }
    return [[self.rowCount objectAtIndex:section] integerValue];
}

- (NSString *)reuseIdentifierWithIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        return nil;
    }
    return [self.reuseIdentifiers objectForKey:indexPath];
}

- (id)layoutInfoWithIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        return nil;
    }
    return [self.layoutInfos objectForKey:indexPath];
}

#pragma mark - Update
- (void)updateSectionCount:(NSInteger)sectionCount
{
    self.sectionCount = sectionCount;
}

- (void)updateRowCount:(NSInteger)rowCount section:(NSInteger)section
{
    if (section < self.rowCount.count) {
        [self.rowCount replaceObjectAtIndex:section withObject:@(rowCount)];
    } else if (section == self.rowCount.count) {
        [self.rowCount addObject:@(rowCount)];
    }
}

- (void)updateReuseIdentifier:(NSString *)reuseIdentifier forIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || !reuseIdentifier) {
        return;
    }
    [self.reuseIdentifiers setObject:reuseIdentifier forKey:indexPath];
}

- (void)updateLayoutInfo:(id)layoutInfo forIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || !layoutInfo) {
        return;
    }
    [self.layoutInfos setObject:layoutInfo forKey:indexPath];
}

#pragma mark - invalidate
- (void)invalidateWithSections:(NSIndexSet *)sections
{
    if (!sections) {
        return;
    }
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        for (int i = 0;i < [self.rowCount[idx] integerValue];i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:idx];
            // 1. reuse identifier
            [self.reuseIdentifiers removeObjectForKey:indexPath];
            // 2. size
            [self.layoutInfos removeObjectForKey:indexPath];
        }
        // 3. item count
        if (idx < [self.rowCount count]) {
            [self.rowCount replaceObjectAtIndex:idx withObject:kNumberZero];
        }
    }];
}

- (void)invalidateWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (!indexPaths) {
        return;
    }
    for (NSIndexPath *indexPath in indexPaths) {
        // 1. reuse identifier
        [self.reuseIdentifiers removeObjectForKey:indexPath];
        // 2. size
        [self.layoutInfos removeObjectForKey:indexPath];
    }
}

- (void)invalidateAllCaches
{
    self.sectionCount = 0;
    [self.rowCount removeAllObjects];
    [self.reuseIdentifiers removeAllObjects];
    [self.layoutInfos removeAllObjects];
}

#pragma mark - Insert
- (void)insertAtSection:(NSInteger)section start:(NSInteger)start end:(NSInteger)end
{
    // 1. section
    self.sectionCount = 0;
    // 2. row
    if (section < self.rowCount.count) {
        [self.rowCount replaceObjectAtIndex:section withObject:kNumberZero];
    }
    NSUInteger count = self.layoutInfos.count;
    NSUInteger insertCount = (end - start + 1);
    if (start < count) {
        for (NSInteger i = count-1; i >= start; i--) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+insertCount inSection:indexPath.section];
            // 3. reuse id
            id reuseId = [self.reuseIdentifiers objectForKey:indexPath];
            if (reuseId) {
                [self.reuseIdentifiers setObject:reuseId forKey:newIndexPath];
                [self.reuseIdentifiers removeObjectForKey:indexPath];
            }
            // 4. size
            id sizeValue = [self.layoutInfos objectForKey:indexPath];
            if (sizeValue) {
                [self.layoutInfos setObject:sizeValue forKey:newIndexPath];
                [self.layoutInfos removeObjectForKey:indexPath];
            }
        }
    }
}

#pragma mark - Delete
- (void)deleteAtSection:(NSInteger)section start:(NSInteger)start end:(NSInteger)end indexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (!indexPaths) {
        return;
    }
    // 1. section
    self.sectionCount = 0;
    // 2. row
    if (section < self.rowCount.count) {
        [self.rowCount replaceObjectAtIndex:section withObject:kNumberZero];
    }
    NSUInteger count = self.layoutInfos.count;
    NSUInteger deleteCount = (end - start + 1);
    // 3. reuse id
    [self.reuseIdentifiers removeObjectsForKeys:indexPaths];
    // 4. size
    [self.layoutInfos removeObjectsForKeys:indexPaths];
    // 5. update
    if (end < count) {
        for (NSInteger i = end; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row-deleteCount inSection:indexPath.section];
            // 3. reuse id
            id reuseId = [self.reuseIdentifiers objectForKey:indexPath];
            if (reuseId) {
                [self.reuseIdentifiers setObject:reuseId forKey:newIndexPath];
                [self.reuseIdentifiers removeObjectForKey:indexPath];
            }
            // 4. size
            id sizeValue = [self.layoutInfos objectForKey:indexPath];
            if (sizeValue) {
                [self.layoutInfos setObject:sizeValue forKey:newIndexPath];
                [self.layoutInfos removeObjectForKey:indexPath];
            }
        }
    }
}

@end
