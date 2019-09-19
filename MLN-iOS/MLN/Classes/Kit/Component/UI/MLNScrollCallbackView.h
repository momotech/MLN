//
//  MLNScrollCallbackView.h
//
//
//  Created by MoMo on 2019/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MLNLuaCore;
@interface MLNScrollCallbackView : UIView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore refreshEnable:(NSNumber *)refreshEnable loadEnable:(NSNumber *)loadEnable;

@end

NS_ASSUME_NONNULL_END
