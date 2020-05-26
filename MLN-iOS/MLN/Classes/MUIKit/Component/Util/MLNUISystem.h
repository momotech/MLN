//
//  MLNUISystem.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "MLNUIStaticExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUISystem : NSObject <MLNUIStaticExportProtocol>

+ (CGFloat)luaui_stateBarHeight;
+ (CGFloat)luaui_navBarHeight;
+ (CGFloat)luaui_homeIndicatorHeight;
+ (CGFloat)luaui_tabBarHeight;

@end

NS_ASSUME_NONNULL_END
