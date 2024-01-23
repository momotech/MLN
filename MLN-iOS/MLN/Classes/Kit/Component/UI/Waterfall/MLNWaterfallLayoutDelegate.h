//
//  MLNWaterfallLayoutDelegate.h
//  MLN
//
//  Created by MoMo on 2019/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNWaterfallLayoutDelegate <NSObject>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout isFullWidthAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (BOOL)headerIsValidWithWaterfallView:(UICollectionView *)waterfallView;
- (BOOL)headerIsSettingInNewWayWithWaterfallView:(UICollectionView *)waterfallView;

@end

NS_ASSUME_NONNULL_END
