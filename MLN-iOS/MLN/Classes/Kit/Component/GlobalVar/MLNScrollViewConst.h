//
//  MLNScrollViewGlobalVar.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNScrollDirectionVertical = 0,
    MLNScrollDirectionHorizontal,
} MLNScrollDirection;

NS_ASSUME_NONNULL_BEGIN

@interface MLNScrollViewConst : NSObject <MLNGlobalVarExportProtocol>

@end

NS_ASSUME_NONNULL_END
