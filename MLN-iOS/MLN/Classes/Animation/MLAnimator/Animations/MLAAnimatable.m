//
// Created by momo783 on 2020/5/19.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import "MLAAnimatable.h"
#import "MLADefines.h"
#import "MLACGUtils.h"
#import "MLALayerExtras.h"
#import <UIKit/UIKit.h>
#import "UIView+AKFrame.h"

NSString * const kMLAViewAlpha = @"view.alpha";
NSString * const kMLAViewColor = @"view.backgroundColor";

NSString * const kMLAViewPosition  = @"view.position";
NSString * const kMLAViewPositionX = @"view.positionX";
NSString * const kMLAViewPositionY = @"view.positionY";

NSString * const kMLAViewScale  = @"view.scale";
NSString * const kMLAViewScaleX = @"view.scaleX";
NSString * const kMLAViewScaleY = @"view.scaleY";

NSString * const kMLAViewRotation  = @"view.rotation";
NSString * const kMLAViewRotationX = @"view.rotationX";
NSString * const kMLAViewRotationY = @"view.rotationY";

NSString *const kMLAViewContentOffset = @"view.contentOffset";
NSString *const kMLAViewTextColor = @"view.textColor";

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

static inline UIColor *UIColorFromRGBA(const CGFloat values[]) {
    return [UIColor colorWithRed:values[0]/255.0 green:values[1]/255.0 blue:values[2]/255.0 alpha:values[3]];
}

static inline void RGBAFromUIColor(CGFloat values[], UIColor *color) {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    values[0] = 255.0 * red; values[1] = 255.0 * green; values[2] = 255.0 * blue; values[3] = alpha;
}

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
            RGBAFromUIColor(values, obj.backgroundColor);
        },
        ^(UIView *obj, const CGFloat values[]) {
            obj.backgroundColor = UIColorFromRGBA(values);
        },
        kThresholdColor,
        kValueCountFours
    },
    {
        kMLAViewPosition,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.akAnimationPosition.x;
            values[1] = obj.akAnimationPosition.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint position = obj.akAnimationPosition;
            position.x = values[0];
            position.y = values[1];
            obj.akAnimationPosition = position;
        },
        kThresholdPoint,
        kValueCountTwo
    },
    {
        kMLAViewPositionX,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.akAnimationPosition.x;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint position = obj.akAnimationPosition;
            position.x = values[0];
            obj.akAnimationPosition = position;
        },
        kThresholdPoint,
        kValueCountOne
    },
    {
        kMLAViewPositionY,
        ^(UIView *obj, CGFloat values[]) {
            values[0] = obj.akAnimationPosition.y;
        },
        ^(UIView *obj, const CGFloat values[]) {
            CGPoint position = obj.akAnimationPosition;
            position.y = values[0];
            obj.akAnimationPosition = position;
        },
        kThresholdPoint,
        kValueCountOne
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
    },
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    {
        kMLAViewContentOffset,
        ^(UIScrollView *obj, CGFloat values[]) {
            SEL content = NSSelectorFromString(@"mlnui_contentView");
            if([obj respondsToSelector:content]) {
                obj = [obj performSelector:content];
            }
            if(obj && [obj respondsToSelector:@selector(contentOffset)]) {
                values_from_point(values, obj.contentOffset);
            }
        },
        ^(UIScrollView *obj, const CGFloat values[]) {
            SEL content = NSSelectorFromString(@"mlnui_contentView");
            if([obj respondsToSelector:content]) {
                obj = [obj performSelector:content];
            }
            if(obj && [obj respondsToSelector:@selector(setContentOffset:)]) {
                obj.contentOffset = values_to_point(values);            }
        },
        kThresholdPoint,
        kValueCountTwo
    },
#pragma clang diagnostic pop

    {
        kMLAViewTextColor,
        ^(UILabel *obj, CGFloat values[]) {
            if ([obj respondsToSelector:@selector(textColor)]) {
                RGBAFromUIColor(values, obj.textColor);
            }
        },
        ^(UILabel *obj, const CGFloat values[]) {
            if ([obj respondsToSelector:@selector(setTextColor:)]) {
                obj.textColor = UIColorFromRGBA(values);
            }
        },
        kThresholdColor,
        kValueCountFours
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

