//
//  MLNUICornerManagerTool.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNUICornerManagerTool.h"
#import "MLNUIViewConst.h"
#import "UIScrollView+MLNUIKit.h"

@implementation MLNUICornerManagerTool

+ (CGFloat)realCornerRadiusWith:(UIView *)targetView
                   cornerRadius:(CGFloat)cornerRadius
{
    CGSize size = targetView.frame.size;
    CGFloat minValue = MIN(size.width, size.height);
    if (minValue > 0.f) {
        CGFloat milRadius =  minValue * .5f;
        cornerRadius = MIN(cornerRadius, milRadius);
        return cornerRadius;
    }
    return 0.f;
}

+ (MLNUICornerRadius)realMultiCornerRadiusWith:(MLNUICornerRadius)multiRadius
                                      size:(CGSize)size
{
    CGFloat minValue = MAX(MIN(size.width * .5f, size.height * .5f), 0);
    MLNUICornerRadius newCornerRadius = multiRadius;
    newCornerRadius.topLeft = MIN(multiRadius.topLeft, minValue);
    newCornerRadius.topRight = MIN(multiRadius.topRight, minValue);
    newCornerRadius.bottomLeft = MIN(multiRadius.bottomLeft, minValue);
    newCornerRadius.bottomRight = MIN(multiRadius.bottomRight, minValue);
    
    return newCornerRadius;
}

+ (MLNUICornerRadius)multiRadius:(MLNUICornerRadius)multiRadius
                        append:(UIRectCorner)corner
                  cornerRadius:(CGFloat)cornerRadius
{
    MLNUICornerRadius radius = multiRadius;
    if (UIRectCornerAllCorners == corner) {
        if (radius.topLeft != cornerRadius || radius.topRight != cornerRadius || radius.bottomLeft != cornerRadius || radius.bottomRight != cornerRadius) {
            radius.topLeft = cornerRadius;
            radius.topRight = cornerRadius;
            radius.bottomLeft = cornerRadius;
            radius.bottomRight = cornerRadius;
        }
    }
    
    if (UIRectCornerTopLeft & corner) {
        if (radius.topLeft != cornerRadius) {
            radius.topLeft = cornerRadius;
        }
    }
    if (UIRectCornerTopRight & corner) {
        if (radius.topRight != cornerRadius) {
            radius.topRight = cornerRadius;
        }
    }
    if (UIRectCornerBottomLeft & corner) {
        if (radius.bottomLeft != cornerRadius) {
            radius.bottomLeft = cornerRadius;
        }
    }
    if (UIRectCornerBottomRight & corner) {
        if (radius.bottomRight != cornerRadius) {
            radius.bottomRight = cornerRadius;
        }
    }
    return radius;
}

+ (BOOL)multiRadius:(MLNUICornerRadius)multiRadius
             equalMultiRadius:(MLNUICornerRadius)equalMultiRadius
{
    return
    multiRadius.topLeft == equalMultiRadius.topLeft
    && multiRadius.topRight == equalMultiRadius.topRight
    && multiRadius.bottomLeft == equalMultiRadius.bottomLeft
    && multiRadius.bottomRight == equalMultiRadius.bottomRight;
}


+ (BOOL)layerModeWith:(MLNUICornerRadius)multiRadius
{
    return multiRadius.topLeft == multiRadius.topRight == multiRadius.bottomLeft == multiRadius.bottomRight;
}

+ (UIBezierPath *)bezierPathWithRect:(CGRect)frame multiRadius:(MLNUICornerRadius)multiRadius
{
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat minRadius = MIN(width * .5f,height * .5f);
    CGFloat radius = multiRadius.topLeft;
    radius = MAX(MIN(minRadius, radius),0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, height/2.0)];
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(0, radius)];
        [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI endAngle:-M_PI_2 clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(0, 0)];
    }
    [path addLineToPoint:CGPointMake(width/2.0,0)];
    
    radius = multiRadius.topRight;
    radius = MAX(MIN(minRadius, radius),0);
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(width - radius, 0)];
        [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(width, 0)];
    }
    [path addLineToPoint:CGPointMake(width, height / 2.0)];
    
    radius = multiRadius.bottomRight;
    radius = MAX(MIN(minRadius, radius), 0);
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(width, height - radius)];
        [path addArcWithCenter:CGPointMake(width - radius, height - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(width, height)];
    }
    [path addLineToPoint:CGPointMake(width / 2.0, height)];
    
    radius = multiRadius.bottomLeft;
    radius = MAX(MIN(minRadius, radius),0);
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(radius, height)];
        [path addArcWithCenter:CGPointMake(radius, height - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(0, height)];
    }
    [path addLineToPoint:CGPointMake(0, height / 2.0)];
    
    return path;
}

+ (UIBezierPath *)bezierPathWithRect:(CGRect)frame multiRadius:(MLNUICornerRadius)multiRadius lineWidth:(CGFloat)lineWidth
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = lineWidth;
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGFloat minRadius = MIN(width * .5f,height * .5f);
    
    CGFloat radius = multiRadius.topLeft;
    radius = MAX(MIN(minRadius, radius),0);
    
    [path moveToPoint:CGPointMake(lineWidth/2.0, height/2.0)];
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(lineWidth/2.0, radius)];
        [path addArcWithCenter:CGPointMake(radius, radius) radius:radius - lineWidth/2.0 startAngle:-M_PI endAngle:-M_PI_2 clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(lineWidth/2.0, lineWidth/2.0)];
    }
    [path addLineToPoint:CGPointMake(width/2.0, lineWidth/2.0)];
    
    radius = multiRadius.topRight;
    radius = MAX(MIN(minRadius, radius),0);
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(width - radius, lineWidth/2.0)];
        [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius - lineWidth/2.0 startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(width - lineWidth/2.0, lineWidth/2.0)];
    }
    [path addLineToPoint:CGPointMake(width - lineWidth/2.0, height/2.0)];
    
    radius = multiRadius.bottomRight;
    radius = MAX(MIN(minRadius, radius), 0);
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(width - lineWidth/2.0, height - radius)];
        [path addArcWithCenter:CGPointMake(width - radius, height - radius) radius:radius - lineWidth/2.0 startAngle:0 endAngle:M_PI_2 clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(width - lineWidth/2.0, height - lineWidth/2.0)];
    }
    [path addLineToPoint:CGPointMake(width / 2.0 - lineWidth/2.0, height - lineWidth/2.0)];
    
    radius = multiRadius.bottomLeft;
    radius = MAX(MIN(minRadius, radius),0);
    if (radius > 0) {
        [path addLineToPoint:CGPointMake(radius, height - lineWidth/2.0)];
        [path addArcWithCenter:CGPointMake(radius, height - radius) radius:radius - lineWidth/2.0 startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(lineWidth/2.0, height - lineWidth/2.0)];
    }
    [path addLineToPoint:CGPointMake(lineWidth/2.0, height / 2.0)];
    
    return path;
}

+ (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner multiRadius:(MLNUICornerRadius)multiRadius
{
    switch (corner) {
        case UIRectCornerTopLeft:
            return multiRadius.topLeft;
            break;
        case UIRectCornerTopRight:
            return multiRadius.topRight;
            break;
        case UIRectCornerBottomLeft:
            return multiRadius.bottomLeft;
            break;
        case UIRectCornerBottomRight:
            return multiRadius.bottomRight;
            break;
        default:
            return multiRadius.topLeft;
            break;
    }
}

 + (CGRect)viewFrame:(UIView *)view
{
    if (!view) {
        return CGRectZero;
    }
    CGRect frame = CGRectZero;
    frame.size = view.frame.size;
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView =  (UIScrollView *)view;
        frame.size = scrollView.mlnui_horizontal?CGSizeMake(MAX(scrollView.contentSize.width,frame.size.width), frame.size.height):CGSizeMake(frame.size.width, MAX(scrollView.contentSize.height,frame.size.height));
    }
    return frame;
}

@end
