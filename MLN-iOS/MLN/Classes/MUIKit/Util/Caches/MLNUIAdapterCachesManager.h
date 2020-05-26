//
//  MLNUIAdapterCachesManager.h
//  
//
//  Created by MoMo on 2019/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIAdapterCachesManager : NSObject

- (NSInteger)sectionCount;
- (NSInteger)rowCountInSection:(NSInteger)section;
- (NSString *)reuseIdentifierWithIndexPath:(NSIndexPath *)indexPath;
- (id)layoutInfoWithIndexPath:(NSIndexPath *)indexPath;

- (void)updateSectionCount:(NSInteger)sectionCount;
- (void)updateRowCount:(NSInteger)rowCount section:(NSInteger)section;
- (void)updateReuseIdentifier:(NSString *)reuseIdentifier forIndexPath:(NSIndexPath *)indexPath;
- (void)updateLayoutInfo:(id)layoutInfo forIndexPath:(NSIndexPath *)indexPath;

- (void)invalidateWithSections:(NSIndexSet *)sections;
- (void)invalidateWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)invalidateAllCaches;

- (void)insertAtSection:(NSInteger)section start:(NSInteger)start end:(NSInteger)end;

- (void)deleteAtSection:(NSInteger)section start:(NSInteger)start end:(NSInteger)end indexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end

NS_ASSUME_NONNULL_END
