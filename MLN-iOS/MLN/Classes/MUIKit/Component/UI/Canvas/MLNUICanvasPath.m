//
//  MLNUICanvasPath.m
//
//
//  Created by MoMo on 2019/5/20.
//

#import "MLNUICanvasPath.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUICanvasConst.h"

@interface MLNUICanvasPath() {
    UIBezierPath *_bezierPath;
}

@end

@implementation MLNUICanvasPath

- (id)mlnui_rawNativeData
{
    return _bezierPath;
}

#pragma mark - getter & setter
- (UIBezierPath *)bezierPath
{
    if (!_bezierPath) {
        _bezierPath = [UIBezierPath bezierPath];
    }
    return _bezierPath;
}

#pragma mark - Export Methods
- (void)luaui_reset
{
    [self.bezierPath removeAllPoints];
}

- (void)luaui_moveTo:(CGFloat)x toY:(CGFloat)y
{
    [self.bezierPath moveToPoint:CGPointMake(x, y)];
}

- (void)luaui_lineTo:(CGFloat)x toY:(CGFloat)y
{
    [self.bezierPath addLineToPoint:CGPointMake(x, y)];
}

- (void)luaui_quadTo:(CGFloat)endX
              endY:(CGFloat)endY
          controlX:(CGFloat)controlX
          controlY:(CGFloat)controlY
{
    [self.bezierPath addQuadCurveToPoint:CGPointMake(endX, endY) controlPoint:CGPointMake(controlX, controlY)];
}

- (void)luaui_cubicTo:(CGFloat)endX
               endY:(CGFloat)endY
          controlX1:(CGFloat)controlX1
          controlY1:(CGFloat)controlY1
          controlX2:(CGFloat)controlX2
          controlY2:(CGFloat)controlY2
{
    [self.bezierPath addCurveToPoint:CGPointMake(endX, endY) controlPoint1:CGPointMake(controlX1, controlY1) controlPoint2:CGPointMake(controlX2, controlY2)];
}

- (void)luaui_addArcWith:(CGFloat)centerX centerY:(CGFloat)centerY radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise
{
    startAngle = startAngle / 360.0 * M_PI * 2;
    endAngle = endAngle / 360.0 * M_PI * 2;
    [self.bezierPath addArcWithCenter:CGPointMake(centerX, centerY) radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
}

- (void)luaui_addArcWith:(CGFloat)centerX centerY:(CGFloat)centerY radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    startAngle = startAngle / 360.0 * M_PI * 2;
    endAngle = endAngle / 360.0 * M_PI * 2;
    [self.bezierPath addArcWithCenter:CGPointMake(centerX, centerY) radius:radius startAngle:startAngle endAngle:endAngle clockwise:endAngle - startAngle];
}

- (void)luaui_addRect:(CGFloat)left top:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom clockwise:(NSNumber *)clockwise
{
    if (clockwise != nil && clockwise.boolValue == YES) {
        [self.bezierPath moveToPoint:CGPointMake(left, top)];
        [self.bezierPath addLineToPoint:CGPointMake(right, top)];
        [self.bezierPath addLineToPoint:CGPointMake(right, bottom)];
        [self.bezierPath addLineToPoint:CGPointMake(left, bottom)];
        [self.bezierPath closePath];
    } else {
        [self.bezierPath moveToPoint:CGPointMake(left, top)];
        [self.bezierPath addLineToPoint:CGPointMake(left, bottom)];
        [self.bezierPath addLineToPoint:CGPointMake(right, bottom)];
        [self.bezierPath addLineToPoint:CGPointMake(right, top)];
        [self.bezierPath closePath];
    }
}

- (void)luaui_addCircle:(CGFloat)cx y:(CGFloat)cy radius:(CGFloat)radius clockwise:(BOOL)clockwise
{
    [self.bezierPath moveToPoint:CGPointMake(cx + radius, cx + radius)];
    [self.bezierPath addArcWithCenter:CGPointMake(cx, cy) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:clockwise];
}

- (void)luaui_addPath:(UIBezierPath *)path
{
    [self.bezierPath appendPath:path];
}

- (void)luaui_closePath
{
    [self.bezierPath closePath];
}

- (void)luaui_lineWidth:(CGFloat)width
{
    self.bezierPath.lineWidth = width;
}

- (void)luaui_stroke
{
    [self.bezierPath stroke];
}

- (void)luaui_setFillType:(MLNUICanvasFillType)fillType
{
    self.bezierPath.usesEvenOddFillRule = (fillType == MLNUICanvasFillTypeEvenOdd);
}

#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(MLNUICanvasPath)
LUAUI_EXPORT_METHOD(reset, "luaui_reset", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(moveTo, "luaui_moveTo:toY:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(lineTo, "luaui_lineTo:toY:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(quadTo, "luaui_quadTo:endY:controlX:controlY:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(cubicTo, "luaui_cubicTo:endY:controlX1:controlY1:controlX2:controlY2:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(arcTo, "luaui_addArcWith:centerY:radius:startAngle:endAngle:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(addArc, "luaui_addArcWith:centerY:radius:startAngle:endAngle:clockwise:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(addPath, "luaui_addPath:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(addRect, "luaui_addRect:top:right:bottom:clockwise:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(addCircle, "luaui_addCircle:y:radius:clockwise:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(lineWidth, "luaui_lineWidth:", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(stroke, "luaui_stroke", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(close, "luaui_closePath", MLNUICanvasPath)
LUAUI_EXPORT_METHOD(setFillType, "luaui_setFillType:", MLNUICanvasPath)
LUAUI_EXPORT_END(MLNUICanvasPath, Path, NO, NULL, NULL)
@end
