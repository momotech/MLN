//
//  MLNValueCalculator.m
//  MLN
//
//  Created by MoMo on 2019/9/6.
//

#import "MLNValueCalculator.h"
#import "MLNKitHeader.h"

@implementation MLNValueCalculator

static MLN_FORCE_INLINE id calculateCGFloat(CGFloat from, CGFloat to, CGFloat interpolation) {
    CGFloat delta = to - from;
    return @(from + delta * interpolation);
}

static MLN_FORCE_INLINE id calculateCGRect(CGRect from, CGRect to, CGFloat interpolation) {
    CGFloat deltaX = to.origin.x - from.origin.x;
    CGFloat deltaY = to.origin.y - from.origin.y;
    CGFloat deltaWidth = to.size.width - from.size.width;
    CGFloat deltaHeight = to.size.height - from.size.height;
    
    return @(CGRectMake(from.origin.x + interpolation * deltaX,
                        from.origin.y + interpolation * deltaY,
                        from.size.width + interpolation * deltaWidth,
                        from.size.height + interpolation * deltaHeight));
}

static MLN_FORCE_INLINE id calculateCGSize(CGSize from, CGSize to, CGFloat interpolation) {
    CGFloat deltaWidth = to.width - from.width;
    CGFloat deltaHeight = to.height - from.height;
    return @(CGSizeMake(from.width + interpolation * deltaWidth,
                        from.height + interpolation * deltaHeight));
}

static MLN_FORCE_INLINE id calculateCGPoint(CGPoint from, CGPoint to, CGFloat interpolation) {
    CGFloat deltaX = to.x - from.x;
    CGFloat deltaY = to.y - from.y;
    return @(CGPointMake(from.x + interpolation * deltaX,
                         from.y + interpolation * deltaY));
}

- (id)calculate:(id)fromValue to:(id)toValue interpolation:(CGFloat)interpolation
{
    if ([fromValue isKindOfClass:[NSNumber class]] &&
        [toValue isKindOfClass:[NSNumber class]] &&
        strcmp([fromValue objCType], [toValue objCType]) == 0) {
#if defined(__LP64__) && __LP64__
        return calculateCGFloat([fromValue doubleValue], [toValue doubleValue], interpolation);
#else
        return calculateCGFloat([fromValue floatValue], [toValue floatValue], interpolation);
#endif
    } else if ([fromValue isKindOfClass:[NSValue class]] &&
        [toValue isKindOfClass:[NSValue class]] &&
        strcmp([fromValue objCType], [toValue objCType]) == 0) {
        
        if (strcmp([fromValue objCType], @encode(CGRect))) {
            return calculateCGRect([fromValue CGRectValue], [toValue CGRectValue], interpolation);
        } else if (strcmp([fromValue objCType], @encode(CGSize))) {
            return calculateCGSize([fromValue CGSizeValue], [toValue CGSizeValue], interpolation);
        } else if (strcmp([fromValue objCType], @encode(CGPoint))) {
            return calculateCGPoint([fromValue CGPointValue], [toValue CGPointValue], interpolation);
        }
    }
    return nil;
}

@end
