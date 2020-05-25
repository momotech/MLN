//
//  MLNUISafeAreaAdapter.m
//  MLNUI
//
//  Created by MoMo on 2019/12/20.
//

#import "MLNUISafeAreaAdapter.h"
#import "MLNUIEntityExporterMacro.h"

@interface MLNUISafeAreaAdapter ()

@property (nonatomic, copy) void(^updateInsetsCallback)(void);

@end
@implementation MLNUISafeAreaAdapter

- (void)setInsetsTop:(CGFloat)insetsTop
{
    if (_insetsTop != insetsTop) {
        _insetsTop = insetsTop;
        [self didUpdateInsets];
    }
}

- (void)setInsetsBottom:(CGFloat)insetsBottom
{
    if (_insetsBottom != insetsBottom) {
        _insetsBottom = insetsBottom;
        [self didUpdateInsets];
    }
}

- (void)setInsetsLeft:(CGFloat)insetsLeft
{
    if (_insetsLeft != insetsLeft) {
        _insetsLeft = insetsLeft;
        [self didUpdateInsets];
    }
}

- (void)setInsetsRight:(CGFloat)insetsRight
{
    if (_insetsRight != insetsRight) {
        _insetsRight = insetsRight;
        [self didUpdateInsets];
    }
}

- (void)didUpdateInsets
{
    if (self.updateInsetsCallback) {
        self.updateInsetsCallback();
    }
}

- (void)updateInsets:(void(^)(void))callback
{
    self.updateInsetsCallback = callback;
}

LUA_EXPORT_BEGIN(MLNUISafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsTop, "setInsetsTop:", "insetsTop", MLNUISafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsBottom, "setInsetsBottom:", "insetsBottom", MLNUISafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsLeft, "setInsetsLeft:", "insetsLeft", MLNUISafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsRight, "setInsetsRight:", "insetsRight", MLNUISafeAreaAdapter)
LUA_EXPORT_END(MLNUISafeAreaAdapter, SafeAreaAdapter, NO, NULL, NULL)

@end
