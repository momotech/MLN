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
@property (nonatomic, strong, readonly) UIView *luaui_contentView;

@property (nonatomic, assign) CGFloat luaui_paddingLeft;
@property (nonatomic, assign) CGFloat luaui_paddingRight;
@property (nonatomic, assign) CGFloat luaui_paddingTop;
@property (nonatomic, assign) CGFloat luaui_paddingBottom;

/**
 当前的padding是否需要更新
 */
@property (nonatomic, assign, getter=luaui_isPaddingNeedUpdated) BOOL luaui_paddingNeedUpdated;

/**
 当视图内部Padding需要更新时候被调用，如果你需要自己处理padding，可以重写该方法。
 
 @warning 不可以主动调用该方法！
 */
- (void)luaui_onUpdateForPadding;

/**
 当视图内部Padding更新后被调用，如果你需要自己处理padding，可以重写该方法。
 
 @warning 不可以主动调用该方法！
 */
- (void)luaui_paddingUpdated;

@end

#endif /* MLNUIPaddingViewProtocol_h */
