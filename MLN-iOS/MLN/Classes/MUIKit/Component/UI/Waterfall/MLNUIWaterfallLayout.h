//
//  MLNUIWaterfallLayout.h
//  
//
//  Created by MoMo on 2018/7/18.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"

@interface MLNUIWaterfallLayout : UICollectionViewFlowLayout <MLNUIEntityExportProtocol>

@property (nonatomic, assign, readonly) CGSize avaliableSizeForLayoutItem;

@end
