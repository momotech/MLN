//
//  MLNViewPagerAdapter.h
//  MLN
//
//  Created by MoMo on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNViewPager.h"

@interface MLNViewPagerAdapter : NSObject <MLNEntityExportProtocol, UICollectionViewDataSource, MLNCycleScrollViewDelegate>

@property (nonatomic, weak) MLNViewPager *viewPager;
@property (nonatomic, assign) NSInteger cellCounts;
@property (nonatomic, weak) UICollectionView *targetCollectionView;

@end
