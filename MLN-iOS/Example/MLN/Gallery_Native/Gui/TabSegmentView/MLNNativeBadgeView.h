//
//  MLNNativeBadgeView.h
//  MLN
//
//  Created by MoMo on 2019/1/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNNativeBadgeView : UIView

/**
 * 显示的文本数字。
 * 传@" "则显示为红点
 * 传nil则隐藏
 * 传@"0"不隐藏
 */
@property (nonatomic, copy) NSString *badgeValue;

/**
 * 背景图切换
 */
@property (nonatomic, strong) UIImage *image;


- (instancetype)initWithFrame:(CGRect)frame;

#pragma mark - 标准控件的初始化方法
- (instancetype)initWithOrigin:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
