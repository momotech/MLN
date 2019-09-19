//
//  MLNSystem.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "MLNStaticExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNSystem : NSObject <MLNStaticExportProtocol>

+ (CGFloat)lua_stateBarHeight;
+ (CGFloat)lua_navBarHeight;
+ (CGFloat)lua_homeIndicatorHeight;
+ (CGFloat)lua_tabBarHeight;

@end

NS_ASSUME_NONNULL_END
