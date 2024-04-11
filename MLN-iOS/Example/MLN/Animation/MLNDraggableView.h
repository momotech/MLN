//
//  MLNDraggableView.h
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/6/17.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,MLATouchType){
    MLATouchType_Begin,
    MLATouchType_Move,
    MLATouchType_End,
    MLATouchType_Cancel,
};

@class MLNDraggableView;

typedef void(^TouchBlock)(MLATouchType type, MLNDraggableView *view, UITouch *touch, UIEvent *event);

@protocol MLNDraggableViewDelegate <NSObject>

- (void)dragView:(MLNDraggableView *)view touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)dragView:(MLNDraggableView *)view touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)dragView:(MLNDraggableView *)view touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)dragView:(MLNDraggableView *)view touchesCanceled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;


@end
@interface MLNDraggableView : UIView
@property (nonatomic, weak) id<MLNDraggableViewDelegate>delegate;
@property (nonatomic, strong) TouchBlock touchBlock;

@end

NS_ASSUME_NONNULL_END
