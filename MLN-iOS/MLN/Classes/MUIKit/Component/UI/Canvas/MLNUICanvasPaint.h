//
//  MLNUICanvasPaint.h
//
//
//  Created by MoMo on 2019/6/5.
//

#import <Foundation/Foundation.h>
#import "MLNUICanvasConst.h"
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUICanvasPaint : NSObject<MLNUIEntityExportProtocol>

@property (nonatomic, strong) UIColor *paintColor;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) NSInteger pathEffect;
@property (nonatomic, assign) NSInteger shader;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) MLNUICanvasDrawStyle style;
@property (nonatomic, strong, readonly) UIFont *font;

- (void)setupContext:(CGContextRef)contextRef;
- (void)strokeBezierPath:(UIBezierPath *)bezierPath;
- (void)fillBezierPath:(UIBezierPath *)bezierPath;

- (void)setupShapeLayer:(CAShapeLayer *)shapeLayer;

@end

NS_ASSUME_NONNULL_END
