//
//  MLNSimpleViewPager.h
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNSimpleViewPager : UIView

- (void)reloadWithDataList:(NSArray *)dataList;
- (void)scrollToPage:(NSUInteger)index aniamted:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
