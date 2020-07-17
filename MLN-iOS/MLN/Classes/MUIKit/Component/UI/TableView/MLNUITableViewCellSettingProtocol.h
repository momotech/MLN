//
//  MLNUITableViewCellSettingProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/10/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNUITableViewCellSettingProtocol <NSObject>

@optional
- (BOOL)isShowPressedColor;
- (UIColor *)pressedColor;

@end

NS_ASSUME_NONNULL_END
