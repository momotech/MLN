//
//  MLNGalleryNavigatorView.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMLNNavigatorHeight 55

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryNavigationBarItem : NSObject

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) dispatch_block_t clickActionBlock;

@end

@interface MLNGalleryNavigationBar : UIView

- (void)setLeftItem:(MLNGalleryNavigationBarItem *)leftItem;
- (void)setRightItem:(MLNGalleryNavigationBarItem *)rightItem;
- (void)setRightItems:(NSArray <MLNGalleryNavigationBarItem *> *)rightItems;
- (void)setTitleView:(UIView *)titleView;
- (void)setTitle:(NSString *)title;
- (void)setMsgNumber:(NSInteger)count;

- (UILabel *)defaultTitleLabel;

- (UIButton *)rightButtonAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
