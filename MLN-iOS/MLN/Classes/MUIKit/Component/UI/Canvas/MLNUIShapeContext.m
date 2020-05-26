//
//  MLNUIShapeContext.m
//
//
//  Created by MoMo on 2019/7/24.
//

#import "MLNUIShapeContext.h"
#import "MLNUIHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"
#import "MLNUICanvasPaint.h"
#import "MLNUICanvasPath.h"

@interface MLNUIShapeContext()

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, strong) NSMutableArray *shapeLayers;

@end

@implementation MLNUIShapeContext

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore TargetView:(UIView *)targetView
{
    if (self =  [super initWithMLNUILuaCore:luaCore]) {
        _targetView = targetView;
    }
    return self;
}

- (void)cleanShapes
{
    [self luaui_clear];
}

#pragma mark - Private

- (NSMutableArray *)shapeLayers
{
    if (!_shapeLayers) {
        _shapeLayers = [NSMutableArray array];
    }
    return _shapeLayers;
}

- (NSArray *)translationColorsToColorArray:(NSArray *)colorsArray
{
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:colorsArray.count];
    for (NSString *colorStr in colorsArray) {
        NSArray *array = [colorStr componentsSeparatedByString:@","];
        if (array.count == 4) {
            CGFloat r = CGFloatValueFromNumber(array[0]) / 255.0;
            CGFloat g = CGFloatValueFromNumber(array[1]) / 255.0;
            CGFloat b = CGFloatValueFromNumber(array[2]) / 255.0;
            CGFloat a = CGFloatValueFromNumber(array[3]);
            [arrayM addObject:(__bridge id)[UIColor colorWithRed:r green:g blue:b alpha:a].CGColor];
        }
    }
    return arrayM;
}

- (NSArray *)locationsWithColorsArray:(NSArray *)colorsArray
{
    if (!colorsArray || colorsArray.count == 0) {
        return @[];
    }
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:colorsArray.count];
    CGFloat offset = 1.0 / colorsArray.count;
    for (NSInteger index = 1; index <= colorsArray.count; index++) {
        [arrayM addObject:@(offset * index)];
    }
    return arrayM;
}

#pragma mark - Export For Lua
- (void)luaui_setFillColor:(UIColor *)fillColor
{
    _targetView.backgroundColor = fillColor;
    _targetView.opaque = YES;
}

- (void)luaui_drawLine:(CGFloat)startX startY:(CGFloat)startY endX:(CGFloat)endX endY:(CGFloat)endY paint:(MLNUICanvasPaint *)paint
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(startX, startY)];
    [path addLineToPoint:CGPointMake(endX, endY)];
    
    CAShapeLayer  *shape = [CAShapeLayer layer];
    [paint setupShapeLayer:shape];
    shape.path = path.CGPath;
    
    [self.targetView.layer addSublayer:shape];
    [self.shapeLayers addObject:shape];
}

- (void)luaui_drawPath:(UIBezierPath *)path paint:(MLNUICanvasPaint *)paint
{
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.fillRule = path.usesEvenOddFillRule?@"even-odd":@"non-zero";
    [paint setupShapeLayer:shape];
    shape.path=  path.CGPath;
    [self.targetView.layer addSublayer:shape];
    [self.shapeLayers addObject:shape];
}

- (void)luaui_drawPoint:(CGFloat)x y:(CGFloat)y paint:(MLNUICanvasPaint *)paint
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(x + paint.width, y)];
    
    CAShapeLayer  *shape = [CAShapeLayer layer];
    [paint setupShapeLayer:shape];
    shape.path = path.CGPath;
    
    [self.targetView.layer addSublayer:shape];
    [self.shapeLayers addObject:shape];
}

- (void)luaui_drawGradientWithStart:(CGFloat)startX startY:(CGFloat)startY endX:(CGFloat)endX endY:(CGFloat)endY colorArray:(NSArray *)colorArray path:(UIBezierPath *)bezierPath
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect frame = self.targetView.frame;
    
    gradientLayer.startPoint = CGPointMake(startX / frame.size.width, startY / frame.size.height);
    gradientLayer.endPoint = CGPointMake(endX / frame.size.width, endY / frame.size.height);
    gradientLayer.frame = self.targetView.bounds;
    gradientLayer.colors = [self translationColorsToColorArray:colorArray];
    gradientLayer.locations = [self locationsWithColorsArray:colorArray];
    gradientLayer.type = kCAGradientLayerAxial;
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = bezierPath.CGPath;
    
    gradientLayer.mask = shape;
    
    [self.targetView.layer addSublayer:gradientLayer];
    [self.shapeLayers addObject:gradientLayer];
}

- (void)luaui_clear
{
    for (CALayer *layer in self.shapeLayers) {
        [layer removeFromSuperlayer];
    }
    [_shapeLayers removeAllObjects];
}

#pragma mark - life style
- (void)dealloc4Lua
{
    [_shapeLayers removeAllObjects];
}

#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(MLNUIShapeContext)
LUAUI_EXPORT_METHOD(clear, "luaui_clear", MLNUIShapeContext)
LUAUI_EXPORT_METHOD(drawColor, "luaui_setFillColor:", MLNUIShapeContext)
LUAUI_EXPORT_METHOD(drawLine, "luaui_drawLine:startY:endX:endY:paint:", MLNUIShapeContext)
LUAUI_EXPORT_METHOD(drawPoint, "luaui_drawPoint:y:paint:", MLNUIShapeContext)
LUAUI_EXPORT_METHOD(drawPath, "luaui_drawPath:paint:", MLNUIShapeContext)
LUAUI_EXPORT_METHOD(drawGradientColor, "luaui_drawGradientWithStart:startY:endX:endY:colorArray:path:", MLNUIShapeContext)
LUAUI_EXPORT_END(MLNUIShapeContext, DrawContext, NO, NULL, NULL)

@end
