//
//  MLNCanvasPath.m
//
//
//  Created by MoMo on 2019/5/20.
//

#import "MLNCanvasPath.h"
#import "MLNViewExporterMacro.h"
#import "MLNCanvasConst.h"

@interface MLNCanvasPath() {
    UIBezierPath *_bezierPath;
}

@end

@implementation MLNCanvasPath

- (id)mln_rawNativeData
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
- (void)lua_reset
{
    [self.bezierPath removeAllPoints];
}

- (void)lua_moveTo:(CGFloat)x toY:(CGFloat)y
{
    [self.bezierPath moveToPoint:CGPointMake(x, y)];
}

- (void)lua_lineTo:(CGFloat)x toY:(CGFloat)y
{
    [self.bezierPath addLineToPoint:CGPointMake(x, y)];
}

- (void)lua_quadTo:(CGFloat)endX
              endY:(CGFloat)endY
          controlX:(CGFloat)controlX
          controlY:(CGFloat)controlY
{
    [self.bezierPath addQuadCurveToPoint:CGPointMake(endX, endY) controlPoint:CGPointMake(controlX, controlY)];
}

- (void)lua_cubicTo:(CGFloat)endX
               endY:(CGFloat)endY
          controlX1:(CGFloat)controlX1
          controlY1:(CGFloat)controlY1
          controlX2:(CGFloat)controlX2
          controlY2:(CGFloat)controlY2
{
    [self.bezierPath addCurveToPoint:CGPointMake(endX, endY) controlPoint1:CGPointMake(controlX1, controlY1) controlPoint2:CGPointMake(controlX2, controlY2)];
}

- (void)lua_addArcWith:(CGFloat)centerX centerY:(CGFloat)centerY radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise
{
    startAngle = startAngle / 360.0 * M_PI * 2;
    endAngle = endAngle / 360.0 * M_PI * 2;
    [self.bezierPath addArcWithCenter:CGPointMake(centerX, centerY) radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
}

- (void)lua_addArcWith:(CGFloat)centerX centerY:(CGFloat)centerY radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    startAngle = startAngle / 360.0 * M_PI * 2;
    endAngle = endAngle / 360.0 * M_PI * 2;
    [self.bezierPath addArcWithCenter:CGPointMake(centerX, centerY) radius:radius startAngle:startAngle endAngle:endAngle clockwise:endAngle - startAngle];
}

- (void)lua_addRect:(CGFloat)left top:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom clockwise:(NSNumber *)clockwise
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

- (void)lua_addCircle:(CGFloat)cx y:(CGFloat)cy radius:(CGFloat)radius clockwise:(BOOL)clockwise
{
    [self.bezierPath moveToPoint:CGPointMake(cx + radius, cx + radius)];
    [self.bezierPath addArcWithCenter:CGPointMake(cx, cy) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:clockwise];
}

- (void)lua_addPath:(UIBezierPath *)path
{
    [self.bezierPath appendPath:path];
}

- (void)lua_closePath
{
    [self.bezierPath closePath];
}

- (void)lua_lineWidth:(CGFloat)width
{
    self.bezierPath.lineWidth = width;
}

- (void)lua_stroke
{
    [self.bezierPath stroke];
}

- (void)lua_setFillType:(MLNCanvasFillType)fillType
{
    self.bezierPath.usesEvenOddFillRule = (fillType == MLNCanvasFillTypeEvenOdd);
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNCanvasPath)
LUA_EXPORT_METHOD(reset, "lua_reset", MLNCanvasPath)
LUA_EXPORT_METHOD(moveTo, "lua_moveTo:toY:", MLNCanvasPath)
LUA_EXPORT_METHOD(lineTo, "lua_lineTo:toY:", MLNCanvasPath)
LUA_EXPORT_METHOD(quadTo, "lua_quadTo:endY:controlX:controlY:", MLNCanvasPath)
LUA_EXPORT_METHOD(cubicTo, "lua_cubicTo:endY:controlX1:controlY1:controlX2:controlY2:", MLNCanvasPath)
LUA_EXPORT_METHOD(arcTo, "lua_addArcWith:centerY:radius:startAngle:endAngle:", MLNCanvasPath)
LUA_EXPORT_METHOD(addArc, "lua_addArcWith:centerY:radius:startAngle:endAngle:clockwise:", MLNCanvasPath)
LUA_EXPORT_METHOD(addPath, "lua_addPath:", MLNCanvasPath)
LUA_EXPORT_METHOD(addRect, "lua_addRect:top:right:bottom:clockwise:", MLNCanvasPath)
LUA_EXPORT_METHOD(addCircle, "lua_addCircle:y:radius:clockwise:", MLNCanvasPath)
LUA_EXPORT_METHOD(lineWidth, "lua_lineWidth:", MLNCanvasPath)
LUA_EXPORT_METHOD(stroke, "lua_stroke", MLNCanvasPath)
LUA_EXPORT_METHOD(close, "lua_closePath", MLNCanvasPath)
LUA_EXPORT_METHOD(setFillType, "lua_setFillType:", MLNCanvasPath)
LUA_EXPORT_END(MLNCanvasPath, Path, NO, NULL, NULL)
@end
