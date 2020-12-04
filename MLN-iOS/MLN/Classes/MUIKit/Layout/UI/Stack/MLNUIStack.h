//
//  MLNUIStack.h
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIView.h"
#import "MLNUIStackConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIStack : MLNUIView

/// 是否事件穿透，若为YES，则该视图不响应触摸事件，但其子视图仍可响应。默认NO.
@property (nonatomic, assign) BOOL argo_eventCross;

@end

@interface MLNUIPlaneStack : MLNUIStack

/// subclass should override
- (void)setLuaui_reverse:(BOOL)reverse;

/// 如果是HStack则只设置高度；如果是VStack则只设置宽度.
- (void)setCrossAxisSize:(CGSize)size;
- (void)setCrossAxisMaxSize:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
