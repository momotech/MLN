//
//  MLNUIViewPagerAdapter.h
//  MLNUI
//
//  Created by MoMo on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"
#import "MLNUIViewPager.h"

@interface MLNUIViewPagerAdapter : NSObject <MLNUIEntityExportProtocol, UICollectionViewDataSource, MLNUICycleScrollViewDelegate>

@property (nonatomic, weak) MLNUIViewPager *viewPager;
@property (nonatomic, assign) NSInteger cellCounts;
@property (nonatomic, weak) UICollectionView *targetCollectionView;

@end
