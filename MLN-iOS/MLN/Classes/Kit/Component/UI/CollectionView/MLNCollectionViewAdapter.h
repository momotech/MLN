//
//  MLNCollectionViewAdapter.h
//  
//
//  Created by MoMo on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "MLNScrollViewDelegate.h"
#import "MLNEntityExportProtocol.h"
#import "MLNCollectionViewGridLayout.h"
#import "MLNCollectionViewAdapterProtocol.h"
#import "MLNCollectionViewGridLayoutDelegate.h"
#import "MLNAdapterCachesManager.h"

@interface MLNCollectionViewAdapter : MLNScrollViewDelegate <MLNCollectionViewAdapterProtocol, UICollectionViewDelegateFlowLayout, MLNCollectionViewGridLayoutDelegate, MLNEntityExportProtocol>

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNBlock *> *initedCellCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNBlock *> *reuseCellCallbacks;
@property (nonatomic, strong, readonly) MLNAdapterCachesManager *cachesManager;

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView  reuseId:(NSString *)reuseId;
- (MLNBlock *)initedCellCallbackByReuseId:(NSString *)reuseId;
- (MLNBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId;

@end
