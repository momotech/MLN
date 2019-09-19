//
//  MLNWaterfallLayout.h
//  
//
//  Created by MoMo on 2018/7/18.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"

@class MLNWaterfallLayout;
@protocol MLNWaterfallLayoutDelegate <NSObject>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

@end

@interface MLNWaterfallLayout : UICollectionViewLayout <MLNEntityExportProtocol>

@end
