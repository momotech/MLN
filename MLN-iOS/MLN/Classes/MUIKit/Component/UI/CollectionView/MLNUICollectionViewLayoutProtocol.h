//
//  MLNCollectionViewLayoutProtocol.h
//  MLN
//
//  Created by MoMo on 2019/9/16.
//

#ifndef MLNCollectionViewLayoutProtocol_h
#define MLNCollectionViewLayoutProtocol_h

#import <UIKit/UIKit.h>
#import "MLNScrollViewConst.h"

@protocol MLNCollectionViewLayoutProtocol <NSObject>

@required
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

- (void)relayoutIfNeed;


@end

#endif /* MLNCollectionViewLayoutProtocol_h */
