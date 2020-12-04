//
//  UIView+AKFrame.m
//  ArgoKit
//
//  Created by MOMO on 2020/11/16.
//

#import "UIView+AKFrame.h"
#import <objc/message.h>

@interface UIView ()

@property (nonatomic, assign) CGFloat akTranslationX;
@property (nonatomic, assign) CGFloat akTranslationY;
@property (nonatomic, assign) CGFloat akScaleX;
@property (nonatomic, assign) CGFloat akScaleY;

@end

@implementation UIView (AKFrame)

#pragma mark - Public (Animation)

- (void)setAkAnimationX:(CGFloat)ax {
   self.akTranslationX = ax - self.akLayoutFrame.origin.x;
   AKViewChangeX(self, ax);
}

- (CGFloat)akAnimationX {
   return self.frame.origin.x;
}

- (void)setAkAnimationY:(CGFloat)ay {
   self.akTranslationY = ay - self.akLayoutFrame.origin.y;
   AKViewChangeY(self, ay);
}

- (CGFloat)akAnimationY {
   return self.frame.origin.y;
}

- (void)setAkAnimationWidth:(CGFloat)width {
   self.akScaleX = width / self.akLayoutFrame.size.width;
   AKViewChangeWidth(self, width);
}

- (CGFloat)akAnimationWidth {
   return self.frame.size.width;
}

- (void)setAkAnimationHeight:(CGFloat)height {
   self.akScaleY = height / self.akLayoutFrame.size.height;
   AKViewChangeHeight(self, height);
}

- (CGFloat)akAnimationHeight {
   return self.frame.size.height;
}

- (void)setAkAnimationPosition:(CGPoint)origin {
   CGPoint layoutOrigin = self.akLayoutFrame.origin;
   self.akTranslationX = origin.x - layoutOrigin.x;
   self.akTranslationY = origin.y - layoutOrigin.y;
   self.center = (CGPoint){ // 相对于原点是为了和Android保持一致
       origin.x + self.layer.anchorPoint.x * self.akLayoutFrame.size.width,
       origin.y + self.layer.anchorPoint.y * self.akLayoutFrame.size.height,
   };
}

- (CGPoint)akAnimationPosition {
   CGPoint origin = (CGPoint){
       self.center.x - self.layer.anchorPoint.x * self.akLayoutFrame.size.width,
       self.center.y - self.layer.anchorPoint.y * self.akLayoutFrame.size.height
   };
   return origin;
}

- (void)setAkAnimationFrame:(CGRect)frame {
   CGRect layoutFrame = self.akLayoutFrame;
   self.akTranslationX = frame.origin.x - layoutFrame.origin.x;
   self.akTranslationY = frame.origin.y - layoutFrame.origin.y;
   self.akScaleX = frame.size.width / layoutFrame.size.width;
   self.akScaleY = frame.size.height / layoutFrame.size.height;
   self.frame = frame;
}

- (CGRect)akAnimationFrame {
   return self.frame;
}

#pragma mark - Public (Layout)

- (void)setAkLayoutFrame:(CGRect)frame {
   objc_setAssociatedObject(self, @selector(akLayoutFrame), [NSValue valueWithCGRect:frame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
   AKViewApplyFrame(self, (CGRect){
       frame.origin.x + self.akTranslationX,
       frame.origin.y + self.akTranslationY,
       frame.size.width * self.akScaleX,
       frame.size.height * self.akScaleY
   });
}

- (CGRect)akLayoutFrame {
   return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}

#pragma mark - Private

static inline void AKViewChangeX(UIView *view, CGFloat x) {
    CGRect frame = view.frame;
    frame.origin.x = x;
    AKViewApplyFrame(view, frame);
}

static inline void AKViewChangeY(UIView *view, CGFloat y) {
    CGRect frame = view.frame;
    frame.origin.y = y;
    AKViewApplyFrame(view, frame);
}

static inline void AKViewChangeWidth(UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    AKViewApplyFrame(view, frame);
}

static inline void AKViewChangeHeight(UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    AKViewApplyFrame(view, frame);
}

static inline void AKViewApplyFrame(UIView *view, CGRect frame) {
    if (!CGAffineTransformEqualToTransform(view.transform, CGAffineTransformIdentity)) {
        CGAffineTransform transform = view.transform;
        view.transform = CGAffineTransformIdentity;
        view.frame = frame;
        view.transform = transform;
    } else if (!CATransform3DEqualToTransform(view.layer.transform, CATransform3DIdentity)) {
        CATransform3D transform = view.layer.transform;
        view.layer.transform = CATransform3DIdentity;
        view.frame = frame;
        view.layer.transform = transform;
    } else {
        view.frame = frame;
    }
}

#pragma mark - Private (Property)

#define AK_PSEUDO_ZERO (-2020)

static inline BOOL AKFloatEqual(CGFloat value1, CGFloat value2) {
    return fabs(value1 - value2) < 0.0001f;
}

- (void)setAkTranslationX:(CGFloat)tx {
    objc_setAssociatedObject(self, @selector(akTranslationX), @(tx), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)akTranslationX {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setAkTranslationY:(CGFloat)ty {
    objc_setAssociatedObject(self, @selector(akTranslationY), @(ty), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)akTranslationY {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setAkScaleX:(CGFloat)sx {
    if (AKFloatEqual(sx, 0.0)) {
        sx = AK_PSEUDO_ZERO;
    }
    objc_setAssociatedObject(self, @selector(akScaleX), @(sx), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)akScaleX {
    CGFloat sx = [objc_getAssociatedObject(self, _cmd) floatValue];
    if (AKFloatEqual(sx, 0.0)) {
        return 1.0f; // default is 1.0
    }
    if (AKFloatEqual(sx, AK_PSEUDO_ZERO)) {
        return 0.0f;
    }
    return sx;
}

- (void)setAkScaleY:(CGFloat)sy {
    if (AKFloatEqual(sy, 0.0)) {
        sy = AK_PSEUDO_ZERO;
    }
    objc_setAssociatedObject(self, @selector(akScaleY), @(sy), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)akScaleY {
    CGFloat sy = [objc_getAssociatedObject(self, _cmd) floatValue];
    if (AKFloatEqual(sy, 0.0)) {
        return 1.0f; // default is 1.0
    }
    if (AKFloatEqual(sy, AK_PSEUDO_ZERO)) {
        return 0.0f;
    }
    return sy;
}

@end
