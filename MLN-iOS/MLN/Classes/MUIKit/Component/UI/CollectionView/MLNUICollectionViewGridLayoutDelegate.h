//
//  MLNUICollectionViewGridLayoutDelegate.h
//  MLNUI
//
//  Created by MoMo on 2019/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNUICollectionViewGridLayoutDelegate <NSObject>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
