//
//  MLNUIOvershotInterpolader.m
//  MLNUI
//
//  Created by MoMo on 2019/9/8.
//

#import "MLNUIOvershotInterpolater.h"

@implementation MLNUIOvershotInterpolater

- (CGFloat)getInterpolation:(CGFloat)progress {
    if (progress == 0) return 0.0;
    if (progress == 1) return 1.0;
    
    progress -= 1.0f;
    return progress * progress * ((2.0 + 1) * progress + 2.0) + 1.0f;
}

@end
