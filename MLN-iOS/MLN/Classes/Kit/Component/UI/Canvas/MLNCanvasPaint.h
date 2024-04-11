//
//  MLNCanvasPaint.h
//
//
//  Created by MoMo on 2019/6/5.
//

#import <Foundation/Foundation.h>
#import "MLNCanvasConst.h"
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNCanvasPaint : NSObject<MLNEntityExportProtocol>

@property (nonatomic, strong) UIColor *paintColor;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) NSInteger pathEffect;
@property (nonatomic, assign) NSInteger shader;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) MLNCanvasDrawStyle style;
@property (nonatomic, strong, readonly) UIFont *font;

- (void)setupContext:(CGContextRef)contextRef;
- (void)strokeBezierPath:(UIBezierPath *)bezierPath;
- (void)fillBezierPath:(UIBezierPath *)bezierPath;

- (void)setupShapeLayer:(CAShapeLayer *)shapeLayer;

@end

NS_ASSUME_NONNULL_END
