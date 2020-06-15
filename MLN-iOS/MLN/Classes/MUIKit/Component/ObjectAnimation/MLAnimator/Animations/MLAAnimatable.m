//
// Created by momo783 on 2020/5/19.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import "MLAAnimatable.h"
#import "MLADefines.h"
#import "MLACGUtils.h"
#import "MLALayerExtras.h"
#import <UIKit/UIKit.h>
#import "UIView+MLNUILayout.h"

NSString * const kMLAViewAlpha = @"view.alpha";
NSString * const kMLAViewColor = @"view.backgroundColor";

NSString * const kMLAViewPosition  = @"view.position";
NSString * const kMLAViewPositionX = @"view.positionX";
NSString * const kMLAViewPositionY = @"view.positionY";

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

// 数值个数
static NSUInteger const kValueCountOne = 1;
static NSUInteger const kValueCountTwo = 2;
static NSUInteger const kValueCountFours = 4;

typedef struct {
    NSString* name;
    MLAValueReadBlock readBlock;
    MLAValueWriteBlock writeBlock;
    CGFloat threshold;
    NSUInteger count;
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
        kThresholdAlpha,
        kValueCountOne,
    },
    {
        kMLAViewColor,
        ^(UIView *obj, CGFloat values[]) {
            MLAUIColorGetRGBAComponents(obj.backgroundColor, values);
        },
        ^(UIView *obj, const CGFloat values[]) {
            obj.backgroundColor = MLAUIColorRGBACreate(values);
        },
        kThresholdColor,
        kValueCountFours
    },
    {
        kMLAViewPosition,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.center.x;
            values[1] = obj.center.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint center = obj.center;
            center.x = values[0];
            center.y = values[1];
            obj.mlnuiAnimationCenter = center;
        },
        kThresholdPoint,
        kValueCountTwo
    },
    {
        kMLAViewPositionX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.center.x;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint center = obj.center;
            center.x = values[0];
            obj.mlnuiAnimationCenter = center;
        },
        kThresholdPoint,
        kValueCountOne
    },
    {
        kMLAViewPositionY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.center.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint center = obj.center;
            center.y = values[0];
            obj.mlnuiAnimationCenter = center;
        },
        kThresholdPoint,
        kValueCountOne
    },
    {
        kMLAViewSize,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.layer.bounds.size.width;
            values[1] = obj.layer.bounds.size.height;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGSize size = CGSizeMake(values[0], values[1]);
            if (size.width < 0.f || size.height < 0.f) {
                return;
            }
            CGRect frame = obj.bounds;
            frame.size = size;
            obj.layer.bounds = frame;
        },
        kThresholdPoint,
        kValueCountTwo
    },
    {
        kMLAViewFrame,
        ^(UIView *obj, CGFloat values[]) {
            CGRect frame = obj.layer.frame;
            values[0] = frame.origin.x;
            values[1] = frame.origin.y;
            values[2] = frame.size.width;
            values[3] = frame.size.height;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGRect frame = CGRectMake(values[0], values[1], values[2], values[3]);
            obj.mlnuiAnimationFrame = frame;
        },
        kThresholdPoint,
        kValueCountFours
    },
    {
        kMLAViewScale,
        ^(UIView *obj, CGFloat values[]) {
            values_from_point(values, MLALayerGetScaleXY(obj.layer));
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetScaleXY(obj.layer, values_to_point(values));
        },
        kThresholdScale,
        kValueCountTwo
    },
    {
        kMLAViewScaleX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetScaleX(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetScaleX(obj.layer, values[0]);
        },
        kThresholdScale,
        kValueCountOne
    },
    {
        kMLAViewScaleY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetScaleY(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetScaleY(obj.layer, values[0]);
        },
        kThresholdScale,
        kValueCountOne
    },
    {
        kMLAViewRotation,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetRotation(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetRotation(obj.layer, values[0]);
        },
        kThresholdRotation,
        kValueCountOne
    },
    {
        kMLAViewRotationX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetRotationX(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
            MLALayerSetRotationX(obj.layer, values[0]);
        },
        kThresholdRotation,
        kValueCountOne
    },
    {
        kMLAViewRotationY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = MLALayerGetRotationY(obj.layer);
        },
        ^(UIView *obj, const CGFloat values[]) {
           MLALayerSetRotationY(obj.layer, values[0]);
        },
        kThresholdRotation,
        kValueCountOne
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

@property(readwrite, nonatomic, strong) NSString *name;

@property(readwrite, nonatomic, strong) MLAValueReadBlock readBlock;

@property(readwrite, nonatomic, strong) MLAValueWriteBlock writeBlock;

@property(readwrite, nonatomic, assign) CGFloat threshold;

@property(readwrite, nonatomic, assign) NSUInteger valueCount;

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
        animatable.valueCount = helper.count;
    } else {
        animatable.readBlock = ^(id obj, CGFloat vlaues[]) {
            NSLog(@"-[MLAAnimatable animatableWithName:] \'name :%@\' target :%@ readBlock  is not exist !!!", name, obj);
        };
        animatable.writeBlock = ^(id obj, const CGFloat vlaues[]) {
            NSLog(@"-[MLAAnimatable animatableWithName:] \'name :%@\' target :%@ readBlock  is not exist !!!", name, obj);
        };
        animatable.threshold = 1.0f;
        animatable.valueCount = kValueCountOne;
    }
    [animatableMaps setObject:animatable forKey:name];
    
    return animatable;
}

@end

@interface MLAMutableAnimatable ()

@end

@implementation MLAMutableAnimatable
@synthesize readBlock;
@synthesize writeBlock;
@synthesize threshold;
@synthesize valueCount;

+ (instancetype)animatableWithName:(NSString *)name {
    MLAMutableAnimatable *mutableAnimatable = [[MLAMutableAnimatable alloc] initWithName:name];
    return mutableAnimatable;
}

@end

