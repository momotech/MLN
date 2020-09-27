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

@class MLNUICollectionViewCell;

@interface MLNUICollectionViewAdapter : MLNUIScrollViewDelegate <MLNUICollectionViewAdapterProtocol, UICollectionViewDelegateFlowLayout, MLNUICollectionViewGridLayoutDelegate, MLNUIEntityExportProtocol>

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *initedCellCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *reuseCellCallbacks;
@property (nonatomic, strong, readonly) MLNUIAdapterCachesManager *cachesManager;

/// Subclass can override
@property (nonatomic, strong, readonly) Class collectionViewCellClass;

/// Subclass can override, indicate no max size if is CGSizeZero.
@property (nonatomic, assign, readonly) CGSize cellMaxSize;

/// Subclass can override, 0 or MLNUIUndefined will be ignored.
- (CGSize)fitSizeForCell:(MLNUICollectionViewCell *)cell;

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView reuseId:(NSString *)reuseId;
- (MLNUIBlock *)initedCellCallbackByReuseId:(NSString *)reuseId;
- (MLNUIBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId;

@end
