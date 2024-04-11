//
//  MLNCollectionViewAdapterProtocol.h
//  
//
//  Created by MoMo on 2019/2/19.
//

#ifndef MLNCollectionViewAdapterProtocol_h
#define MLNCollectionViewAdapterProtocol_h
#import <UIKit/UIKit.h>
#import "MLNCollectionViewGridLayoutDelegate.h"

@class MLNBlock;

@protocol MLNCollectionViewAdapterProtocol <UICollectionViewDataSource, UICollectionViewDelegate, MLNCollectionViewGridLayoutDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)collectionViewReloadData:(UICollectionView *)collectionView;
- (void)collectionView:(UICollectionView *)collectionView reloadSections:(NSIndexSet *)sections;

- (void)collectionView:(UICollectionView *)collectionView insertItemsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem;
- (void)collectionView:(UICollectionView *)collectionView deleteItemsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem indexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)collectionView:(UICollectionView *)collectionView deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)collectionView:(UICollectionView *)collectionView reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView longPressItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* MLNCollectionViewAdapterProtocol_h */
