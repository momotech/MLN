//
//  MLNAnimationTestController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/6/17.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNAnimationTestController.h"
#import "MLAAnimation.h"
#import "MLNDraggableView.h"

#define SWAP(x,y) do { typeof(x) SWAP = x; x = y; y = SWAP; } while(0)

@interface MLNAnimationTestController () <MLNDraggableViewDelegate> {
    CGPoint _beganPoint;
    CGPoint _lastPoint;
    float _endDistance;
}

@property (nonatomic, strong) MLASpringAnimation *springToTop;
@property (nonatomic, strong) MLASpringAnimation *springToBottom;

@property (nonatomic, weak) UIView *pane;
@property (nonatomic, strong) dispatch_block_t animationBuilder;
@property (nonatomic, assign) BOOL paneClosed;

@end

@implementation MLNAnimationTestController

- (void)createAnimation {
    MLASpringAnimation *toTop = [[MLASpringAnimation alloc] initWithValueName:kMLAViewPositionY tartget:self.pane];
//        s.fromValue = self.paneClosed ? ff : tt;
    toTop.toValue = @(self.pane.center.y - self.view.bounds.size.height * .5);
    toTop.springBounciness = 10;
    toTop.springSpeed = 8;
    toTop.dynamicsFriction = 15;
    
    self.springToTop = toTop;
    
    MLASpringAnimation *toBottom = [[MLASpringAnimation alloc] initWithValueName:kMLAViewPositionY tartget:self.pane];
//        s.fromValue = self.paneClosed ? ff : tt;
    toBottom.toValue = @(self.pane.center.y);
    toBottom.springBounciness = 10;
    toBottom.springSpeed = 8;
    toBottom.dynamicsFriction = 15;
    
    self.springToBottom = toBottom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize size = self.view.bounds.size;
    MLNDraggableView *v = [[MLNDraggableView alloc] initWithFrame:CGRectMake(0, size.height * .75, size.width, size.height)];
    v.backgroundColor = [UIColor grayColor];
    [self.view addSubview:v];
    self.pane = v;
    v.delegate = self;
    self.paneClosed = YES;
    
    [self createAnimation];
//    id ff = @(v.center.y);
//    id tt = @(v.center.y - size.height * .5);
    
    
//    UITapGestureRecognizer *tap  =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//    [self.view addGestureRecognizer:tap];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:@"Tap" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [b addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    b.frame = CGRectMake(200, 60, 40, 80);
    [self.view addSubview:b];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self doSpring];
}

- (void)finishSprint {
    [self.springToTop finish];
    [self.springToBottom finish];
}

- (void)doSpring {
//    self.animationBuilder();
//    self.paneClosed = !self.paneClosed;

    [self finishSprint];
    BOOL toTop = abs(self.pane.center.y - [self.springToTop.toValue floatValue]) > abs(self.pane.center.y - [self.springToBottom.toValue floatValue]);
    
    if (!toTop) {
        [self.springToBottom start:^(MLAAnimation *animation, BOOL finish) {
            NSLog(@"to  bottom finish");
        }];
    } else {
        [self.springToTop start:^(MLAAnimation *animation, BOOL finish) {
            NSLog(@"to  top finish");
        }];
    }
}


- (void)dragView:(MLNDraggableView *)view touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self finishSprint];
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:view.superview];
    _beganPoint = p;
    _lastPoint = p;
}

- (void)dragView:(MLNDraggableView *)view touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:view.superview];
    CGPoint diff = CGPointMake(p.x - _lastPoint.x, p.y - _lastPoint.y);
    diff.x = 0;
    [self updateView:view diff:diff];
    _lastPoint = p;
    NSLog(@"move %@",NSStringFromCGPoint(p));
}

- (void)dragView:(MLNDraggableView *)view touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self doSpring];
}

- (void)dragView:(MLNDraggableView *)view touchesCanceled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self doSpring];
}

- (void)updateView:(UIView *)view diff:(CGPoint)p {
    CGPoint center = view.center;
    center.x += p.x;
    center.y += p.y;
    view.center = center;
}

@end
