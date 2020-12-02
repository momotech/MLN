#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MLAAnimatable.h"
#import "MLAAnimation.h"
#import "ArgoAnimation.h"
#import "NSObject+Animator.h"
#import "UIView+AKFrame.h"
#import "MLAAnimator.h"
#import "MLADefines.h"
#import "MLAInteractiveBehaviorProtocol.h"
#import "MLAValueAnimation+Interactive.h"

FOUNDATION_EXPORT double ArgoAnimationVersionNumber;
FOUNDATION_EXPORT const unsigned char ArgoAnimationVersionString[];
