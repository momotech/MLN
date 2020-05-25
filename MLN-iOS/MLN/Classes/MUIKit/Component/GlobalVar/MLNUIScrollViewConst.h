//
//  MLNUIScrollViewGlobalVar.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNUIScrollDirectionVertical = 0,
    MLNUIScrollDirectionHorizontal,
} MLNUIScrollDirection;

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIScrollViewConst : NSObject <MLNUIGlobalVarExportProtocol>

@end

NS_ASSUME_NONNULL_END
