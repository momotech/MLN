//
//  MLNCollectionViewGridLayout.h
//
//
//  Created by MoMo on 2018/12/14.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNScrollViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNCollectionViewGridLayout;
@protocol MLNCollectionViewGridLayoutDelegate <NSObject>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MLNCollectionViewGridLayout : UICollectionViewLayout<MLNEntityExportProtocol>

@property (nonatomic, assign) MLNScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END
