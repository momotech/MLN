//
//  MLNGestureRecognizer.h
//  EventTrasmition
//
//  Created by MOMO on 2020/2/6.
//  Copyright © 2020年 xiaotei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNGestureHoldObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLNGestureRecognizerDelegate;

@interface MLNGestureRecognizer : UIGestureRecognizer

@property (nonatomic, weak) id<MLNGestureRecognizerDelegate> mln_delegate;

// before touch end set true cancel onClick onTouch callback
@property (nonatomic, assign) BOOL shouldCancelClick;

@end

@protocol MLNGestureRecognizerDelegate <NSObject>

- (void)mln_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)mln_touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)mln_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)mln_touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)mln_tapAction:(MLNGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
