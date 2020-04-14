//
//  MLNRepeatAnimationGroup.m
//  MLN
//
//  Created by asnail on 2020/4/14.
//

#import "MLNRepeatAnimationGroup.h"

#define kCanvasAnimationCapcity 2

@interface MLNRepeatAnimationGroup ()

@property (nonatomic, strong) NSMutableDictionary<NSString *,MLNRepeatAnimation *> *animations;

@end

@implementation MLNRepeatAnimationGroup

- (MLNRepeatAnimation *)animationForKey:(NSString *)key
{
    return nil;
}



//- (NSMutableDictionary<NSString *,MLNRepeatAnimation *> *)animations
//{
//    if (!_animations) {
//        _animations = [NSMutableDictionary dictionaryWithCapacity:kCanvasAnimationCapcity];
//    }
//    return _animations;
//}

@end
