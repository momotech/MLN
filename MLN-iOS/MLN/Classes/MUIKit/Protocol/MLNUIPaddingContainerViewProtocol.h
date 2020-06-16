//
//  MLNUIPaddingViewProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/6/19.
//

#ifndef MLNUIPaddingViewProtocol_h
#define MLNUIPaddingViewProtocol_h
#import <UIKit/UIKit.h>

/**
 带有Padding效果的视图协议。
 */
@protocol MLNUIPaddingContainerViewProtocol <NSObject>

/**
 被padding包裹的内容视图。
 */
@property (nonatomic, strong, readonly) UIView *mlnui_contentView;

@property (nonatomic, assign, readonly) CGFloat mlnui_paddingLeft;
@property (nonatomic, assign, readonly) CGFloat mlnui_paddingRight;
@property (nonatomic, assign, readonly) CGFloat mlnui_paddingTop;
@property (nonatomic, assign, readonly) CGFloat mlnui_paddingBottom;

@end

#endif /* MLNUIPaddingViewProtocol_h */
