//
//  MLNUICanvasConst.h
//
//
//  Created by MoMo on 2019/7/19.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNUICanvasDrawStyleStroke = 0,
    MLNUICanvasDrawStyleFill,
    MLNUICanvasDrawStyleFillStroke,
} MLNUICanvasDrawStyle;

typedef enum : NSUInteger {
    MLNUICanvasFillTypeWinding = 0,
    MLNUICanvasFillTypeEvenOdd,
} MLNUICanvasFillType;

NS_ASSUME_NONNULL_BEGIN

@interface MLNUICanvasConst : NSObject <MLNUIGlobalVarExportProtocol>


@end

NS_ASSUME_NONNULL_END
