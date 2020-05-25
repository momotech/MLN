//
//  MLNUIAnimationSet.m
//  MLNUI
//
//  Created by MoMo on 2019/5/16.
//

#import "MLNUIAnimationSet.h"
#import "MLNUIKitHeader.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"

#define kCanvasCapcity 2

@interface MLNUIAnimationSet()

@property (nonatomic, assign) BOOL shareInterpolator;

@property (nonatomic, strong) NSMutableArray<MLNUICanvasAnimation*> *animationsArray;
@property (nonatomic, strong) NSMutableArray<CAAnimation *> *animationsGroupArray;

@end

@implementation MLNUIAnimationSet

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore shareInterpolator:(NSNumber *)shareInterpolator
{
    if (self = [super init]) {
        if (shareInterpolator) {
            _shareInterpolator = shareInterpolator.boolValue;
        }
        
    }
    return self;
}

- (NSArray<CAAnimation *> *)animationValues
{
    return _animationsGroupArray;
}

#pragma mark - copy
- (id)copyWithZone:(NSZone *)zone
{
    MLNUIAnimationSet *copy = [super copyWithZone:zone];
    copy.shareInterpolator = _shareInterpolator;
    copy.animationsArray = [_animationsArray mutableCopy];
    copy.animationsGroupArray = [_animationsGroupArray mutableCopy];
    return copy;
}


#pragma mark - getter & setter
- (NSMutableArray *)animationsArray
{
    if (!_animationsArray) {
        _animationsArray = [NSMutableArray arrayWithCapacity:kCanvasCapcity];
    }
    return _animationsArray;
}

- (NSMutableArray *)animationsGroupArray
{
    if (!_animationsGroupArray) {
        _animationsGroupArray = [NSMutableArray arrayWithCapacity:kCanvasCapcity];
    }
    return _animationsGroupArray;
}

#pragma mark - Export Method
- (void)luaui_addAnimation:(MLNUICanvasAnimation *)animation
{
    if (!animation || ![animation isKindOfClass:[MLNUICanvasAnimation class]]) {
        MLNUIKitLuaAssert(NO, @"animation type must be canvas animation!");
        return;
    }
    //Android端会按索引来，到了就执行，故做一次copy操作，不影响多次使用
    animation = [animation copy];
    [self.animationsArray addObject:animation];
    animation.animationGroup.animations = [animation animationValues];
    self.duration = MAX(self.duration, animation.duration * animation.repeatCount + animation.delay);
    self.animationGroup.duration = self.duration;
    self.pivotX = animation.pivotX;
    self.pivotXType = animation.pivotXType;
    self.pivotY = animation.pivotY;
    self.pivotYType = animation.pivotYType;
    [self.animationsGroupArray addObject:animation.animationGroup];
}

- (void)setDuration:(CGFloat)duration
{
    [super setDuration:duration];
}


#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUIAnimationSet)
LUA_EXPORT_METHOD(addAnimation, "luaui_addAnimation:", MLNUIAnimationSet)
LUA_EXPORT_END(MLNUIAnimationSet, AnimationSet, YES, "MLNUICanvasAnimation", "initWithMLNUILuaCore:shareInterpolator:")
@end
