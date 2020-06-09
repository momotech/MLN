//
// Created by momo783 on 2020/5/19.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import "MLAAnimatable.h"
#import "MLADefines.h"
#import "MLACGUtils.h"
#import "MLALayerExtras.h"
#import <UIKit/UIKit.h>

NSString * const kMLAViewAlpha = @"view.alpha";
NSString * const kMLAViewColor = @"view.backgroundColor";

NSString * const kMLAViewOrigin  = @"view.origin";
NSString * const kMLAViewOriginX = @"view.originX";
NSString * const kMLAViewOriginY = @"view.originY";

NSString * const kMLAViewCenter  = @"view.center";
NSString * const kMLAViewCenterX = @"view.centerX";
NSString * const kMLAViewCenterY = @"view.centerY";

NSString * const kMLAViewSize  = @"view.size";
NSString * const kMLAViewFrame = @"view.frame";

NSString * const kMLAViewScale  = @"view.scale";
NSString * const kMLAViewScaleX = @"view.scaleX";
NSString * const kMLAViewScaleY = @"view.scaleY";

NSString * const kMLAViewRotation  = @"view.rotation";
NSString * const kMLAViewRotationX = @"view.rotationX";
NSString * const kMLAViewRotationY = @"view.rotationY";


// 计算精度
static CGFloat const kThresholdColor = 0.01;
static CGFloat const kThresholdPoint = 1.0;
static CGFloat const kThresholdAlpha = 0.01;
static CGFloat const kThresholdScale = 0.005;
static CGFloat const kThresholdRotation = 0.01;

typedef struct {
    NSString* name;
    MLAValueReadBlock readBlock;
    MLAValueWriteBlock writeBlock;
    CGFloat threshold;
} _MLAValueHelper;
typedef _MLAValueHelper MLAValueHelper;

static MLAValueHelper kStaticHelpers[] =
{
    {
        kMLAViewAlpha,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.alpha;
        },
        ^(UIView *obj, const CGFloat values[]) {
            obj.alpha = values[0];
        },
        kThresholdAlpha
    },
    {
        kMLAViewColor,
        ^(UIView *obj, CGFloat values[]) {
            MLAUIColorGetRGBAComponents(obj.backgroundColor, values);
        },
        ^(UIView *obj, const CGFloat values[]) {
            obj.backgroundColor = MLAUIColorRGBACreate(values);
        },
        kThresholdColor
    },
    {
        kMLAViewOrigin,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.frame.origin.x;
            values[1] = obj.frame.origin.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGRect frame = obj.frame;
            frame.origin.x = values[0];
            frame.origin.y = values[1];
            obj.frame = frame;
        },
        kThresholdPoint
    },
    {
        kMLAViewOriginX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.frame.origin.x;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGRect frame = obj.frame;
            frame.origin.x = values[0];
            obj.frame = frame;
        },
        kThresholdPoint
    },
    {
        kMLAViewOriginY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.frame.origin.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGRect frame = obj.frame;
            frame.origin.y = values[0];
            obj.frame = frame;
        },
        kThresholdPoint
    },
    {
        kMLAViewCenter,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.center.x;
            values[1] = obj.center.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint center = obj.center;
            center.x = values[0];
            center.y = values[1];
            obj.center = center;
        },
        kThresholdPoint
    },
    {
        kMLAViewCenterX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.center.x;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint center = obj.center;
            center.x = values[0];
            obj.center = center;
        },
        kThresholdPoint
    },
    {
        kMLAViewSize,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.frame.size.width;
            values[1] = obj.frame.size.height;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGRect frame = obj.frame;
            frame.size.width = values[0];
            frame.size.height = values[1];
            obj.frame = frame;
        },
        kThresholdPoint
    },
    {
        kMLAViewFrame,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.frame.origin.x;
            values[1] = obj.frame.origin.y;
            values[2] = obj.frame.size.width;
            values[3] = obj.frame.size.height;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGRect frame = obj.frame;
            frame.origin.x = values[0];
            frame.origin.y = values[1];
            frame.size.width = values[2];
            frame.size.height = values[3];
            obj.frame = frame;
        },
        kThresholdPoint
    },
    {
        kMLAViewCenterY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.center.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint center = obj.center;
            center.y = values[0];
            obj.center = center;
        },
        kThresholdPoint
    },
    {
        kMLAViewScale,
        ^(UIView *obj, CGFloat values[]) {
            values_from_point(values, MLALayerGetScaleXY(obj.layer));
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetScaleXY(obj.layer, values_to_point(values));
        },
        kThresholdScale
    },
    {
        kMLAViewScaleX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetScaleX(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetScaleX(obj.layer, values[0]);
        },
        kThresholdScale
    },
    {
        kMLAViewScaleY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetScaleY(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetScaleY(obj.layer, values[0]);
        },
        kThresholdScale
    },
    {
        kMLAViewRotation,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetRotation(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetRotation(obj.layer, values[0]);
        },
        kThresholdRotation
    },
    {
        kMLAViewRotationX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetRotationX(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetRotationX(obj.layer, values[0]);
        },
        kThresholdRotation
    },
    {
        kMLAViewRotationY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetRotationY(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
           MLALayerSetRotationY(obj.layer, values[0]);
        },
        kThresholdRotation
    }
};

#pragma mark - Static Method
static NSUInteger helperIndexInSatticStates(NSString *name)
{
    NSUInteger index = 0;
    while (index < MLA_ARRAY_COUNT(kStaticHelpers)) {
        if (kStaticHelpers[index].name == name) {
            return index;
        }
        index ++;
    }
    return NSNotFound;
}

#pragma mark - MLAAnimatable

@interface MLAAnimatable ()

@end

static NSMutableDictionary<NSString *, MLAAnimatable*> *animatableMaps;
@implementation MLAAnimatable

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

+ (instancetype)animatableWithName:(NSString *)name
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animatableMaps = [NSMutableDictionary dictionary];
    });
    
    MLAAnimatable *animatable = [animatableMaps objectForKey:name];
    if (animatable) {
        return animatable;
    }
    
    NSInteger index = helperIndexInSatticStates(name);
    animatable = [[MLAAnimatable alloc] initWithName:name];
    if (index != NSNotFound) {
        MLAValueHelper helper = kStaticHelpers[index];
        animatable.readBlock = helper.readBlock;
        animatable.writeBlock = helper.writeBlock;
        animatable.threshold = helper.threshold;
    } else {
        animatable.readBlock = ^(id obj, CGFloat vlaues[]) {
            NSLog(@"-[MLAAnimatable animatableWithName:] \'name :%@\' target :%@ readBlock  is not exist !!!", name, obj);
        };
        animatable.writeBlock = ^(id obj, const CGFloat vlaues[]) {
            NSLog(@"-[MLAAnimatable animatableWithName:] \'name :%@\' target :%@ readBlock  is not exist !!!", name, obj);
        };
        animatable.threshold = 1.0f;
    }
    [animatableMaps setObject:animatable forKey:name];
    
    return animatable;
}

@end

