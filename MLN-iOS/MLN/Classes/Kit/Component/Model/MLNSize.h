//
//  MLNSize.h
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 用来处理Lua 与原生交互使用CGSize的场景，只用于转换，原生不需要使用该类
 */
@interface MLNSize : NSValue <MLNEntityExportProtocol>

+ (instancetype)sizeWithCGSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
