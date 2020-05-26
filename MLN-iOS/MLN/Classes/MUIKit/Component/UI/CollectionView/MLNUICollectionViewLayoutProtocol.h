//
//  MLNUICollectionViewLayoutProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/9/16.
//

#ifndef MLNUICollectionViewLayoutProtocol_h
#define MLNUICollectionViewLayoutProtocol_h

#import <UIKit/UIKit.h>
#import "MLNUIScrollViewConst.h"

@protocol MLNUICollectionViewLayoutProtocol <NSObject>

@required
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

- (void)relayoutIfNeed;


@end

#endif /* MLNUICollectionViewLayoutProtocol_h */
