//
//  MLNUICollectionView.h
//  
//
//  Created by MoMo on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"
#import "MLNUIScrollCallbackView.h"
#import "MLNUICollectionViewAdapterProtocol.h"

@interface MLNUICollectionView : MLNUIScrollCallbackView <MLNUIEntityExportProtocol>

@property (nonatomic, weak) id<MLNUICollectionViewAdapterProtocol> adapter;

@end

