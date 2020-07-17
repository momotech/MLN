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
@property (nonatomic, strong) UIButton *alphaButton;

@property (nonatomic, strong) MLASpringAnimation *toBigScale;
@property (nonatomic, strong) MLASpringAnimation *toSmallScale;

@property (nonatomic, strong) MLAObjectAnimation *toBigAlpha;
@property (nonatomic, strong) MLAObjectAnimation *toSmallAlpha;
@property (nonatomic, strong) MLAObjectAnimation *toBigCenter;
@property (nonatomic, strong) MLAObjectAnimation *toSmallCenter;

@property (nonatomic, strong) MLAMultiAnimation *toBigScaleAndAlpha;
@property (nonatomic, strong) MLAMultiAnimation *toSmallScaleAndAlpha;

@property (nonatomic, strong) MLAMultiAnimation *toBig;
@property (nonatomic, strong) MLAMultiAnimation *toSmall;

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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    button.frame = CGRectMake(self.scaleView.bounds.size.width - 25, 10, 20, 20);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 10;
    self.alphaButton = button;
    [self.scaleView addSubview:button];
    
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
    self.toBigScale = [[MLASpringAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    self.toBigScale.toValue = @(CGPointMake(1/_scaleFactor, 1/_scaleFactor));
    [self configSpring:self.toBigScale];
    
    self.toSmallScale = [[MLASpringAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    self.toSmallScale.toValue = @(CGPointMake(1, 1));
    [self configSpring:self.toSmallScale];
    
    //
    CGFloat bigAlpha = 1, smallAlpha = 0;
    CGPoint bigCenter = self.view.center;
    CGPoint smallCenter = CGPointMake(bigCenter.x, bigCenter.y + 200);
    self.scaleView.center = smallCenter;
    self.alphaButton.alpha = smallAlpha;
    
    CGFloat duration = .25;
    CGFloat centerDura = .15;
    
    self.toBigAlpha = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewAlpha tartget:self.alphaButton];
    self.toBigAlpha.toValue = @(bigAlpha);
    self.toBigAlpha.duration = duration;
    
    self.toSmallAlpha = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewAlpha tartget:self.alphaButton];
    self.toSmallAlpha.toValue = @(smallAlpha);
    self.toSmallAlpha.duration = duration;
    
    self.toBigCenter = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewPosition tartget:self.scaleView];
    self.toBigCenter.toValue = @(bigCenter);
    self.toBigCenter.duration = centerDura;
    
    self.toSmallCenter = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewPosition tartget:self.scaleView];
    self.toSmallCenter.toValue = @(smallCenter);
    self.toSmallCenter.duration = centerDura;
    
    self.toBig = [[MLAMultiAnimation alloc] init];
    [self.toBig runTogether:@[self.toBigScale, self.toBigAlpha, self.toBigCenter]];

    self.toSmall = [[MLAMultiAnimation alloc] init];
    [self.toSmall runTogether:@[self.toSmallScale, self.toSmallAlpha, self.toSmallCenter]];
    
    self.touchAnimation = [[MLAObjectAnimation alloc] initWithValueName:kMLAViewScale tartget:self.scaleView];
    float d = 1 + (1/_scaleFactor - 1) / 1.5;
    self.touchAnimation.toValue = @(CGPointMake(d, d));
    
    MLNUIInteractiveBehavior *behavior = [[MLNUIInteractiveBehavior alloc] initWithType:InteractiveType_Gesture];
    behavior.targetView = self.scaleView;
    behavior.direction = InteractiveDirection_Y;
    behavior.endDistance = 100;
    behavior.overBoundary = NO;
    behavior.enable = YES;
//    behavior.followEnable  = YES;
    
    behavior.touchBlock = ^(MLNUITouchType type,CGFloat dx, CGFloat dy, CGFloat dis, CGFloat velocity) {
        NSLog(@"touch type %lu ... dis %.2f velocity %.2f ",(unsigned long)type,dis,velocity);
        if (dis >= 100) {
            [self setExpanded:NO];
            [self.toSmall start:^(MLAAnimation *animation, BOOL finish) {
                NSLog(@"touch to small");
            }];
        }
        if (type == MLNUITouchType_End && dis != 0.00) {
            if (velocity >= 0 && dis > 70) {
                [self gotoSmall:@"touch to small"];
            } else {
                [self gotoBig:@"touch to big"];
            }
        }
    };
    
//    MLNUIInteractiveBehavior *touchAlpha = behavior.copy;
//    touchAlpha.touchBlock = nil;
    [self.toSmallAlpha addInteractiveBehavior:behavior];
    [self.touchAnimation addInteractiveBehavior:behavior];
    
    self.touchBehavior = behavior;
}

- (void)tapAction {
    if (_expanded) {
        [self gotoSmall:@"to small finish"];
    } else {
        [self gotoBig:@"to big finish"];
    }
    [self setExpanded:!_expanded];
}

- (void)setExpanded:(BOOL)ex {
    _expanded = ex;
    self.touchBehavior.enable = _expanded;
}

- (void)gotoBig:(NSString *)log {
    [self.toBig finish];
    [self.toBig start:^(MLAAnimation *animation, BOOL finish) {
        NSLog(@"%@",log);
    }];
}

- (void)gotoSmall:(NSString *)log {
    [self.toSmall finish];
    [self.toSmall start:^(MLAAnimation *animation, BOOL finish) {
        NSLog(@"%@",log);
    }];
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
