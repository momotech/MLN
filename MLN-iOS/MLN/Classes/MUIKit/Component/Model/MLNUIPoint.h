//
//  MLNUIPoint.h
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import <Foundation/Foundation.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 用来处理Lua 与原生交互使用CGPoint的场景，只用于转换，原生不需要使用该类
 */
@interface MLNUIPoint : NSValue <MLNUIEntityExportProtocol>

+ (instancetype)pointWithCGPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
