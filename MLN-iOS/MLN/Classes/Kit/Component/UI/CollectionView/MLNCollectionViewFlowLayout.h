//
//  MLNCollectionViewFlowLayout.h
//  
//
//  Created by MoMo on 2018/7/17.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNCollectionViewLayoutProtocol.h"

@interface MLNCollectionViewFlowLayout : UICollectionViewFlowLayout <MLNCollectionViewLayoutProtocol, MLNEntityExportProtocol>

@end
