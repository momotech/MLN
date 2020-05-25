//
//  MLNUICollectionViewAdapter.h
//  
//
//  Created by MoMo on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "MLNUIScrollViewDelegate.h"
#import "MLNUIEntityExportProtocol.h"
#import "MLNUICollectionViewGridLayout.h"
#import "MLNUICollectionViewAdapterProtocol.h"
#import "MLNUICollectionViewGridLayoutDelegate.h"
#import "MLNUIAdapterCachesManager.h"

@interface MLNUICollectionViewAdapter : MLNUIScrollViewDelegate <MLNUICollectionViewAdapterProtocol, UICollectionViewDelegateFlowLayout, MLNUICollectionViewGridLayoutDelegate, MLNUIEntityExportProtocol>

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *initedCellCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *reuseCellCallbacks;
@property (nonatomic, strong, readonly) MLNUIAdapterCachesManager *cachesManager;

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView  reuseId:(NSString *)reuseId;
- (MLNUIBlock *)initedCellCallbackByReuseId:(NSString *)reuseId;
- (MLNUIBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId;

@end
