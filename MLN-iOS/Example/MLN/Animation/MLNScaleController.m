//
//  MLNScaleController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/6/18.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNScaleController.h"
#import "MLAAnimation.h"
#import "MLNUIInteractiveBehavior.h"
#import "MLAValueAnimation+Interactive.h"

@interface MLNScaleController () {
    float _scaleFactor;
    BOOL _expanded;
}
@property (nonatomic, strong) UIView *scaleView;

@property (nonatomic, strong) MLASpringAnimation *toBig;
@property (nonatomic, strong) MLASpringAnimation *toSmall;

@property (nonatomic, strong) MLAObjectAnimation *touchAnimation;
@property (nonatomic, strong) MLNUIInteractiveBehavior *touchBehavior;
@end

@implementation MLNScaleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _scaleFactor = .5;
    CGSize size = self.view.bounds.size;
    CGSize nSize = CGSizeMake(size.width * _scaleFactor, size.height * _scaleFactor);
    
    CGRect r = CGRectMake(size.width * (1 - _scaleFactor)/2, size.height * (1 - _scaleFactor)/2, nSize.width, nSize.height);
    UIView *drag = [[UIView alloc] initWithFrame:r];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:drag.bounds];
    imgView.image = [UIImage imageNamed:@"pdf@2x.jpeg"];
//    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [drag addSubview:imgView];
    self.scaleView = drag;
    [self.view addSubview:drag];
    
    [self createAnimation];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:@"Tap" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [b addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    b.frame = CGRectMake(200, 60, 40, 80);
    [self.view addSubview:b];
}

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
//    _endDistance = 100;
    
    self.touchAnimation = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    float d = 1 + (1/_scaleFactor - 1) / 1.5;
    self.touchAnimation.toValue = @(CGPointMake(d, d));
    
    MLNUIInteractiveBehavior *behavior = [[MLNUIInteractiveBehavior alloc] initWithType:InteractiveType_Gesture];
    behavior.targetView = self.scaleView;
    behavior.direction = InteractiveDirection_Y;
    behavior.endDistance = 100;
    behavior.overBoundary = NO;
    behavior.enable = YES;
    behavior.startBlock = ^{
        NSLog(@"touch begin ...");
    };
    behavior.finishBlock = ^{
        NSLog(@"touch finish ...");
    };
    behavior.touchBlock = ^(float dx, float dy, float dis, float velocity) {
        if (dis >= 100 && _expanded) {
            _expanded = NO;
            [self.toSmall finish];
            [self.toSmall start:^(MLAAnimation *animation, BOOL finish) {
                NSLog(@"touch to small");
            }];
        }
    };
    [self.touchAnimation addInteractiveBehavior:behavior];
    self.touchBehavior = behavior;
    
}

- (void)tapAction {
//    [self.toBig finish];
//    [self.toSmall finish];
    
    if (_expanded) {
        [self.toSmall start:^(MLAAnimation *animation, BOOL finish) {
            NSLog(@"to small finish");
        }];
    } else {
        [self.toBig start:^(MLAAnimation *animation, BOOL finish) {
            NSLog(@"to big finish");
        }];
    }
    _expanded = !_expanded;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
