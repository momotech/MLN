//
//  MLNDebuggerMenu.m
//  MLN_Example
//
//  Created by MoMo on 2018/8/15.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "MLNFloatingMenu.h"
#import "MLNUIBundle.h"

#define kMenuWidth 140.f
#define kSubIconWidth 35.f
#define kCenterIconWidth 50.f
#define kSpacing 15.f

@interface MLNFloatingMenu () <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) NSArray<UIImageView *> *items;
@property (nonatomic, strong) NSArray<UISnapBehavior *> *snaps;
@property(nonatomic,strong)UIDynamicAnimator *animator;
@property (nonatomic, assign) BOOL isOpen;

@end
@implementation MLNFloatingMenu

- (void)didMoveToSuperview
{
    self.iconView.frame = CGRectMake(kCenterIconWidth, kCenterIconWidth, kCenterIconWidth, kCenterIconWidth);
    [self commonSetup];
}

- (void)commonSetup
{
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *snaps = [NSMutableArray array];
    NSUInteger count = self.iconNames.count;
    if (self.subviews.count >= count) return;
    for (int i = 0; i < count; i++) {
        UIImageView *item = [[UIImageView alloc] init];
        item.tag =  i;
        if ([self.delegate respondsToSelector:@selector(floatingMenu:imageWithName:)]) {
            item.image =  [self.delegate floatingMenu:self imageWithName:self.iconNames[i]];
        }
        item.userInteractionEnabled = YES;
        [self insertSubview:item belowSubview:self.iconView];
        item.frame = CGRectMake(0, 0, kSubIconWidth, kSubIconWidth);
        item.center = self.iconView.center;
        item.alpha = 0;
        item.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapAction:)];
        [item addGestureRecognizer:tap];
        UISnapBehavior *snap = [[UISnapBehavior alloc]initWithItem:item snapToPoint:item.center];
        snap.damping=arc4random_uniform(10)/10.0;
        [array addObject:item];
        [snaps addObject:snap];
    }
    self.items = [array copy];
    self.snaps = [snaps copy];
}

- (void)setFrame:(CGRect)frame
{
    CGSize size = CGSizeMake(kMenuWidth, kMenuWidth);
    frame.size = size;
    [super setFrame:frame];
}

- (void)panAction:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint pt = [gestureRecognizer translationInView:self.superview];
    CGFloat centX = self.center.x +pt.x;
    CGFloat minCenterX = self.frame.size.width * 0.5f - kCenterIconWidth;
    centX = MAX(minCenterX, centX);
    CGFloat maxCenterX = self.superview.frame.size.width - minCenterX;
    centX = MIN(maxCenterX, centX);
    CGFloat centY = self.center.y +pt.y;
    CGFloat minCenterY = self.frame.size.height * 0.5f - kCenterIconWidth +  CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    centY = MAX(minCenterY, centY);
    CGFloat maxCenterY = self.superview.frame.size.height - self.frame.size.height * 0.5f;
    centY = MIN(maxCenterY, centY);
    self.center = CGPointMake(centX , centY);
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
}

- (void)itemTapAction:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(floatingMenu:didSelectedAtIndex:)]) {
        [self.delegate floatingMenu:self didSelectedAtIndex:gestureRecognizer.view.tag];
    }
}

- (void)tapAction
{
    self.isOpen ? [self close] : [self open];
}

- (void)open
{
    NSUInteger count = self.iconNames.count;
    self.isOpen = YES;
    [self.animator removeAllBehaviors];
    for (int i = 0; i < count; i++) {
        UISnapBehavior *snap = self.snaps[i];
        if (@available(iOS 9.0, *)) {
            snap.snapPoint = [self centerForSphereAtIndex:i];
        } else {
            // Fallback on earlier versions
        }
        [self.animator addBehavior:snap];
    }
}

- (void)close
{
    NSUInteger count = self.iconNames.count;
    self.isOpen = NO;
    [self.animator removeAllBehaviors];
    for (int i = 0; i < count; i++) {
        UISnapBehavior *snap = self.snaps[i];
        if (@available(iOS 9.0, *)) {
            snap.snapPoint = self.iconView.center;
        } else {
            // Fallback on earlier versions
        }
        [self.animator addBehavior:snap];
    }
}

- (CGPoint)centerForSphereAtIndex:(int)index
{
    CGFloat raduio = 57.5f;
    CGFloat ao = (index * 45.f);
    CGFloat x = self.iconView.center.x - raduio * cos(ao * M_PI/180);
    CGFloat y = self.iconView.center.y - raduio * sin(ao * M_PI /180);
    return CGPointMake(x, y);
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator
{
    NSUInteger count = self.iconNames.count;
    for (int i = 0; i < count; i++) {
        UIImageView *icon = self.items[i];
        icon.alpha = 1.f;
    }
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    NSUInteger count = self.iconNames.count;
    if (!self.isOpen) {
        for (int i = 0; i < count; i++) {
            UIImageView *icon = self.items[i];
            icon.alpha = 0.f;
        }
    } else {
        for (int i = 0; i < count; i++) {
            UIImageView *icon = self.items[i];
            icon.alpha = 1.f;
        }
    }
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kCenterIconWidth, kCenterIconWidth, kCenterIconWidth, kCenterIconWidth)];
        NSString *path = [[MLNUIBundle UIBundle] pngPathWithName:@"lua"];
        _iconView.image = [UIImage imageWithContentsOfFile:path];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_iconView addGestureRecognizer:tapGesture];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_iconView addGestureRecognizer:pan];
        [pan requireGestureRecognizerToFail:tapGesture];
        [self addSubview:_iconView];
    }
    return _iconView;
}

-(UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
        _animator.delegate = self;
    }
    return _animator;
}

@end
