//
//  MLNCollectionView.h
//  
//
//  Created by MoMo on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNScrollCallbackView.h"
#import "MLNCollectionViewAdapterProtocol.h"
#import "MLNCollectionViewGridLayout.h"

@interface MLNCollectionView : MLNScrollCallbackView <MLNEntityExportProtocol>

@property (nonatomic, weak) id<MLNCollectionViewAdapterProtocol> adapter;

@end

