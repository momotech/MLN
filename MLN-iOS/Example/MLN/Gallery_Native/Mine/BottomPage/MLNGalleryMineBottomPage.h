//
//  MLNGalleryMineBottomPage.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLNGalleryMinePageCellBaseModel;
NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMineBottomPage : UIView

@property (nonatomic, strong) NSArray<MLNGalleryMinePageCellBaseModel*>* bottomModels;
@property (nonatomic, weak) id<UIScrollViewDelegate> segmentViewHandler;

- (void)scrollToPage:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
