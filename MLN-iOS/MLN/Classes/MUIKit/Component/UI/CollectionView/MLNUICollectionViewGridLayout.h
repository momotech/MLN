//
//  MLNUICollectionViewGridLayout.h
//
//
//  Created by MoMo on 2018/12/14.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"
#import "MLNUIScrollViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUICollectionViewGridLayout : UICollectionViewLayout<MLNUIEntityExportProtocol>

@property (nonatomic, assign) MLNUIScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END
