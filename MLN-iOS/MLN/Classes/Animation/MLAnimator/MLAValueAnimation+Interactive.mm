//
//  MLAValueAnimation+Interactive.m
//  ArgoUI
//
//  Created by MOMO on 2020/6/18.
//

#import "MLAValueAnimation+Interactive.h"
#import "MLAAnimationPrivate.h"
#import "MLADefines.h"
#import "MLAAnimator+Private.h"
#import "MLAAnimatable.h"
#import "MLAAnimationRuntime.h"
#import "NSObject+Animator.h"
#import "NSObject+Hash.h"

#include "ObjectAnimation.h"
#include "SpringAnimation.h"
#include "MultiAnimation.h"
#include "CustomAnimation.h"
#include "MLAActionEnabler.h"

#import "MLADefines.h"
#import "MLAAnimatable.h"
//#import "MLNUIInteractiveBehavior.h"

@interface MLAValueAnimation ()
@property(nonatomic, strong) MLAAnimatable *animatable;
@end

@implementation MLAValueAnimation (Interactive)

static BezierControlPoints staticControls[] = {
        {.9, .4, .2,  .7},      // Default
        {0.0, 0.0, 1.0,  1.0},  // Linear
        {0.42, 0.0, 1.0, 1.0},  // EaseIn
        {0.0, 0.0, 0.58, 1.0},  // EaseOut
        {0.25, 0.1, 0.25, 1.0}, // Ease
        {0.42, 0.0, 0.58, 1.0}, // EaseInOut
        {.47, .91, .47, .91},   // custom
        {.61, 1.11, 0.16, .89}, // custom
        {.66, .77, .22, .94},   // custom
};

- (void)updateWithFactor:(CGFloat)factor isBegan:(BOOL)isBegan {

    if (isBegan) {
        self.obscureFrom = nil;
        return;
    }
   VectorRef fromVec = nullptr, toVec = nullptr;
    AMTInt valueCount = (AMTInt)self.animatable.valueCount;
    
    id ff = self.fromValue;
    if (!ff) {
        ff = self.obscureFrom;
    }
    
    if (ff) {
        NSUInteger fromValueCount = 0;
        MLAValueType valueType = kMLAValueUnknown;
        fromVec = MLAUnbox(ff, valueType, fromValueCount, false);
        if (valueCount != fromValueCount) {
            fromVec = nullptr;
        }
    }
    
    MLAValueType toType = kMLAValueUnknown;
    if (self.toValue) {
        NSUInteger toValueCount = 0;
        toVec = MLAUnbox(self.toValue, toType, toValueCount, false);
        if (valueCount != toValueCount) {
            toVec = nullptr;
        }
    }
    
    if (!fromVec) {
        Vector4r vec = read_values(self.animatable.readBlock, self.target, valueCount);
        fromVec = VectorRef(Vector::new_vector(valueCount, vec));
    }
    if (!toVec) {
        Vector4r vec = read_values(self.animatable.readBlock, self.target, valueCount);
        toVec = VectorRef(Vector::new_vector(valueCount, vec));
    }
    
    if (toType != kMLAValueUnknown && !self.obscureFrom) {
        self.obscureFrom = MLABox(fromVec, toType);
    }

    VectorRef current = VectorRef(Vector::new_vector(valueCount, fromVec->data()));

    BezierControlPoints controlPoints = staticControls[1];
    
    AMTFloat t;
    int integer_part = factor;
    CGFloat decimal_part = factor - integer_part;
    if (factor < 0) {
        integer_part = -integer_part;
        decimal_part = -decimal_part;
        for (int i = 0; i < valueCount; i++) {
            toVec->data()[i] = 2 * fromVec->data()[i] - toVec->data()[i];
        }
    }

    VectorRef adjustFrom = VectorRef(Vector::new_vector(valueCount, fromVec->data()));
    VectorRef adjustTo = VectorRef(Vector::new_vector(valueCount, toVec->data()));
    for (int i = 0; i < valueCount; i++) {
        CGFloat f = fromVec->data()[i] + (toVec->data()[i] - fromVec->data()[i]) * integer_part;
        adjustFrom->data()[i] = f;
        CGFloat t = toVec->data()[i] + (toVec->data()[i] - fromVec->data()[i]) * integer_part;
        adjustTo->data()[i] = t;
    }
    
    t = MathUtil::TimingFunctionSolve(controlPoints, decimal_part, SOLVE_EPS(10));
    MathUtil::InterpolateVector(valueCount, current->data(), adjustFrom->data(), adjustTo->data(), t);
    for (int i = 0; i < valueCount; i++) {
        CGFloat c = current->data()[i];
        if (c < 0) {
            current->data()[i] = -c;
        }
        if (c > 3.4 && [self.valueName isEqualToString:@"view.scale"]) {
            current->data()[i] = 3.4;
        }
    }
    self.animatable.writeBlock(self.target, current->data());
}

- (void)addInteractiveBehavior:(id<MLAInteractiveBehaviorProtocol>)behavior {
    [behavior addAnimation:self];
    if (!self.behaviors) {
        self.behaviors = [NSMutableArray array];
    }
    if (behavior) {
        [self.behaviors addObject:behavior];
    }
}

- (void)removeInteractiveBehavior:(id<MLAInteractiveBehaviorProtocol>)behavior {
    if (behavior) {
        [behavior removeAnimation:self];
        [self.behaviors removeObject:behavior];
    }
}

@end
