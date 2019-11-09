//
//  MLNGalleryMineBottomPage.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLNGalleryMineBottomCellModel;
NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMineBottomPage : UIView

@property (nonatomic, strong) NSArray<MLNGalleryMineBottomCellModel*>* bottomModels;
@property (nonatomic, weak) id<UIScrollViewDelegate> segmentViewHandler;

- (void)scrollToPage:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
