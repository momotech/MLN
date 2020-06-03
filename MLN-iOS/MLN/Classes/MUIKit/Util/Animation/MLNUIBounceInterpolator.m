//
//  MLNUIBounceInterpolator.m
//  MLNUI
//
//  Created by MoMo on 2019/9/4.
//

#import "MLNUIBounceInterpolator.h"
#import "MLNUIKitHeader.h"

@implementation MLNUIBounceInterpolator

static MLNUI_FORCE_INLINE CGFloat bounce(CGFloat t) {
    return t * t * 8.0f;
}

- (CGFloat)getInterpolation:(CGFloat)progress {
    progress *= 1.1226f;
    if (progress < 0.3535f) return bounce(progress);
    else if (progress < 0.7408f) return bounce(progress - 0.54719f) + 0.7f;
    else if (progress < 0.9644f) return bounce(progress - 0.8526f) + 0.9f;
    else return bounce(progress - 1.0435f) + 0.95f;
}

@end
