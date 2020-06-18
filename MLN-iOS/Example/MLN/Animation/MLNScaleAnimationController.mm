//
//  MLNScaleAnimationController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/6/17.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNScaleAnimationController.h"
#import "MLAAnimation.h"
#import "MLNDraggableView.h"
#import "MLAAnimationPrivate.h"
#import "MLAValueAnimation+Interactive.h"

@interface MLAAnimation (TT) <MLAAnimationPrivate>
@end

@interface MLNScaleAnimationController () <MLNDraggableViewDelegate> {
    CGPoint _beganPoint;
    CGPoint _lastPoint;
    float _endDistance;
    BOOL _animating;
    float _scaleFactor;
    BOOL _expanded;
}
@property (nonatomic, weak) MLNDraggableView *scaleView;

@property (nonatomic, strong) MLASpringAnimation *toBig;
@property (nonatomic, strong) MLASpringAnimation *toSmall;

@property (nonatomic, strong) MLAObjectAnimation *touchAnimation;
@end

@implementation MLNScaleAnimationController

- (void)configSpring:(MLASpringAnimation *)spring {
    spring.springBounciness = 10;
    spring.springSpeed = 10;
    spring.dynamicsFriction = 15;
}
- (void)createAnimation {
    self.toBig = [[MLASpringAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    self.toBig.toValue = @(CGPointMake(1/_scaleFactor, 1/_scaleFactor));
    [self configSpring:self.toBig];
    
    self.toSmall = [[MLASpringAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    self.toSmall.toValue = @(CGPointMake(1, 1));
    [self configSpring:self.toSmall];
    _endDistance = 100;
    
    self.touchAnimation = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    float d = 1 + (1/_scaleFactor - 1) / 1.5;
    self.touchAnimation.toValue = @(CGPointMake(d, d));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    float factor = .5;
    _scaleFactor = .5;
    
    CGSize size = self.view.bounds.size;
    CGSize nSize = CGSizeMake(size.width * _scaleFactor, size.height * _scaleFactor);
    
    CGRect r = CGRectMake(size.width * (1 - _scaleFactor)/2, size.height * (1 - _scaleFactor)/2, nSize.width, nSize.height);
    MLNDraggableView *drag = [[MLNDraggableView alloc] initWithFrame:r];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:drag.bounds];
    imgView.image = [UIImage imageNamed:@"pdf@2x.jpeg"];
//    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [drag addSubview:imgView];
    self.scaleView = drag;
    [self.view addSubview:drag];
    
//    drag.delegate = self;
    [self configDragView];
    [self createAnimation];
    
//    UITapGestureRecognizer *tap  =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//    [self.scaleView addGestureRecognizer:tap];
//
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:@"Tap" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [b addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    b.frame = CGRectMake(200, 60, 40, 80);
    [self.view addSubview:b];
    
}

- (void)finishAnimation {
    [self.toBig finish];
    [self.toSmall finish];
}

- (void)doSpring:(MLNDraggableView *)view {
    [self finishAnimation];
    _animating = YES;
    if (_expanded) {
        _expanded = NO;
        [self.toSmall start:^(MLAAnimation *animation, BOOL finish) {
            _animating = NO;
        }];
    } else {
        _expanded = YES;
        [self.toBig start:^(MLAAnimation *animation, BOOL finish) {
            _animating = NO;
        }];
    }
}

- (void)tapAction {
    if (_animating) {
        return;
    }
    [self doSpring:self.scaleView];
}

- (void)configDragView {
    __weak __typeof(self)weakSelf = self;
    self.scaleView.touchBlock = ^(MLATouchType type, MLNDraggableView * _Nonnull view, UITouch * _Nonnull touch, UIEvent * _Nonnull event) {
        if (_animating) return;
        __strong __typeof(weakSelf)self = weakSelf;
        if (type == MLATouchType_Begin) {
            CGPoint p = [touch locationInView:view.superview];
            _beganPoint = p;
            _lastPoint = p;
        } else if (type == MLATouchType_Move) {
            if (self.scaleView.transform.a == 1) {
                return;
            }
            CGPoint p = [touch locationInView:view.superview];
            CGPoint diff = CGPointMake(p.x - _lastPoint.x, p.y - _lastPoint.y);
            diff.x = 0;
            CGPoint diffBegin = CGPointMake(p.x - _beganPoint.x, p.y - _beganPoint.y);
            if (diffBegin.y < 0) {
                return;
            }
            if (diffBegin.y < _endDistance) {
                [self.touchAnimation updateWithFactor:diffBegin.y / _endDistance];
            } else {
                [self doSpring:view];
            }
        } else if (type == MLATouchType_End || type == MLATouchType_Cancel) {
            
        }
    };
}

- (void)dragView:(MLNDraggableView *)view touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_animating) {
        return;
    }
    [self finishAnimation];
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:view.superview];
    _beganPoint = p;
    _lastPoint = p;
}

- (void)dragView:(MLNDraggableView *)view touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.scaleView.transform.a == 1 || _animating) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:view.superview];
    CGPoint diff = CGPointMake(p.x - _lastPoint.x, p.y - _lastPoint.y);
    diff.x = 0;
//    [self updateView:view diff:diff];
    _lastPoint = p;
//    NSLog(@"move %@",NSStringFromCGPoint(p));
    
    CGPoint diffBegin = CGPointMake(p.x - _beganPoint.x, p.y - _beganPoint.y);
    if (diffBegin.y < 0) {
        return;
    }
    if (diffBegin.y < _endDistance) {
//        animator::Animation * ani = [self.toSmall cplusplusAnimation];
//        [self.toSmall updateWithFactor:diffBegin.y / 50];
        [self.touchAnimation updateWithFactor:diffBegin.y / _endDistance];
    } else {
        if (diffBegin.y > _endDistance * 1) {
            [self doSpring:view];
        }
    }
    
    NSLog(@"move %.2f ",diffBegin.y);
}

- (void)dragView:(MLNDraggableView *)view touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:view.superview];
    CGPoint diffBegin = CGPointMake(p.x - _beganPoint.x, p.y - _beganPoint.y);
    if (diffBegin.y < 0) {
        return;
    }
    if (diffBegin.y < _endDistance) {
        [self doSpring:view];
    }
}

- (void)dragView:(MLNDraggableView *)view touchesCanceled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

//- (void)updateView:(UIView *)view diff:(CGPoint)p {
//    CGPoint center = view.center;
//    center.x += p.x;
//    center.y += p.y;
//    view.center = center;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
