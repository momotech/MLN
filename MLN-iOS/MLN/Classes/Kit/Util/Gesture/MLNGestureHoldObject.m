//
//  MLNGestureHoldObject.m
//  AFNetworking
//
//  Created by MOMO on 2020/2/6.
//

#import "MLNGestureHoldObject.h"

@implementation MLNGestureHoldObject

- (instancetype)initWithGesture:(UIGestureRecognizer *)mln_gesture
{
    if (self = [super init]) {
        _mln_gesture = mln_gesture;
    }
    return self;
}

@end
