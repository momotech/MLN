//
//  MLNUIScrollCallbackView.h
//
//
//  Created by MoMo on 2019/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MLNUILuaCore;
@interface MLNUIScrollCallbackView : UIView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore refreshEnable:(NSNumber *)refreshEnable loadEnable:(NSNumber *)loadEnable;

@end

NS_ASSUME_NONNULL_END
