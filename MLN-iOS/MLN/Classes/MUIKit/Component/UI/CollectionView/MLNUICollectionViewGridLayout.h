//
//  MLNCollectionViewGridLayout.h
//
//
//  Created by MoMo on 2018/12/14.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNScrollViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNCollectionViewGridLayout : UICollectionViewLayout<MLNEntityExportProtocol>

@property (nonatomic, assign) MLNScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END
