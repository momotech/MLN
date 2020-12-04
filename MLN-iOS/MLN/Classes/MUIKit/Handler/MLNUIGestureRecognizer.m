//
//  MLNUIGestureRecognizer.m
//  ArgoUI
//
//  Created by MOMO on 2020/10/30.
//

#import "MLNUIGestureRecognizer.h"

@interface MLNUIGestureTargetActionContext : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@end

@implementation MLNUIGestureTargetActionContext

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super init]) {
        _target = target;
        _action = action;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (![object isKindOfClass:[MLNUIGestureTargetActionContext class]]) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    MLNUIGestureTargetActionContext *ctx = (MLNUIGestureTargetActionContext *)object;
    return (self.target == ctx.target) && (self.action == ctx.action);
}

- (NSUInteger)hash {
    return [self.target hash] ^ (NSUInteger)sel_getName(self.action);
}

@end

#pragma mark -

@interface MLNUIGestureRecognizer ()

@property (nonatomic, strong) NSMutableArray<MLNUIGestureTargetActionContext *> *targetActions;

@end

@implementation MLNUIGestureRecognizer

#pragma mark - Public

- (void)addTarget:(id)target action:(SEL)action {
    if (!target || !action) return;
    MLNUIGestureTargetActionContext *context = [[MLNUIGestureTargetActionContext alloc] initWithTarget:target action:action];
    if ([self.targetActions containsObject:context]) {
        return;
    }
    [self.targetActions addObject:context];
}

- (void)removeTarget:(id)target action:(SEL)action {
    if (!target && !action) return;
    
    NSUInteger index = 0;
    while (index < self.targetActions.count) {
        MLNUIGestureTargetActionContext *context = self.targetActions[index++];
        if (!context.target) { // the target is deallocating
            [self.targetActions removeObject:context];
            index--;
            continue;
        }
        if (context.target == target && context.action == action) {
            [self.targetActions removeObject:context];
            break;
        }
    }
}

- (void)handleTargetActionsWithGestureRecognizer:(__kindof UIGestureRecognizer<MLNUIGestureRecogizerDelegate> *)gesture {
    if (self.targetActions.count == 0) {
        return;
    }
    [self.targetActions enumerateObjectsUsingBlock:^(MLNUIGestureTargetActionContext *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj.target respondsToSelector:obj.action]) {
#pragma clang disagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj.target performSelector:obj.action withObject:gesture];
#pragma clang disagnostic pop
        }
    }];
}

#pragma mark - Private

- (NSMutableArray<MLNUIGestureTargetActionContext *> *)targetActions {
    if (!_targetActions) {
        _targetActions = [NSMutableArray array];
    }
    return _targetActions;
}

@end
