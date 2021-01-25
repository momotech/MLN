//
//  MLNUIPinchGestureRecognizer.m
//  ArgoUI
//
//  Created by MOMO on 2020/10/30.
//

#import "MLNUIPinchGestureRecognizer.h"

@interface MLNUIPinchGestureRecognizer ()

@property (nonatomic, strong) MLNUIGestureRecognizer *gesture;

@end

@implementation MLNUIPinchGestureRecognizer

#pragma mark - Override

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        [self.gesture addTarget:target action:action];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    [super addTarget:target action:action];
    [self.gesture addTarget:target action:action];
}

- (void)removeTarget:(id)target action:(SEL)action {
    [super removeTarget:target action:action];
    [self.gesture removeTarget:target action:action];
}

#pragma mark - MLNUIGestureRecogizerDelegate

@dynamic argoui_state;

- (void)argoui_handleTargetActions {
    [self.gesture handleTargetActionsWithGestureRecognizer:self];
}

#pragma mark - Private

- (MLNUIGestureRecognizer *)gesture {
    if (!_gesture) {
        _gesture = [MLNUIGestureRecognizer new];
    }
    return _gesture;
}


@end
