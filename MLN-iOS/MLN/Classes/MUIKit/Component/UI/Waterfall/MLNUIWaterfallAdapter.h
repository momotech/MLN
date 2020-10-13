//
//  MLNUIWaterfallAdapter.h
//  
//
//  Created by MoMo on 2018/7/18.
//

#import "MLNUICollectionViewAdapter.h"
#import "MLNUIWaterfallLayoutDelegate.h"
#import "MLNUIWaterfallLayout.h"

@interface MLNUIWaterfallAdapter : MLNUICollectionViewAdapter <MLNUIWaterfallLayoutDelegate>

/// Subclass should override
@property (nonatomic, strong, readonly) Class headerViewClass;

/// Subclass can override if needed
- (CGSize)headerViewMaxSize:(UICollectionReusableView *)headerView;

/// Subclass should override
- (CGSize)headerViewFitSize:(UICollectionReusableView *)headerView;

@end
