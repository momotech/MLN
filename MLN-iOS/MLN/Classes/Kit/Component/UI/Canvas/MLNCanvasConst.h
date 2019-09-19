//
//  MLNCanvasConst.h
//
//
//  Created by MoMo on 2019/7/19.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNCanvasDrawStyleStroke = 0,
    MLNCanvasDrawStyleFill,
    MLNCanvasDrawStyleFillStroke,
} MLNCanvasDrawStyle;

typedef enum : NSUInteger {
    MLNCanvasFillTypeWinding = 0,
    MLNCanvasFillTypeEvenOdd,
} MLNCanvasFillType;

NS_ASSUME_NONNULL_BEGIN

@interface MLNCanvasConst : NSObject <MLNGlobalVarExportProtocol>


@end

NS_ASSUME_NONNULL_END
