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

@property (nonatomic, strong, readonly) MLNUIBlock *initedHeaderCallback;
@property (nonatomic, strong, readonly) MLNUIBlock *reuseHeaderCallback;

@end
