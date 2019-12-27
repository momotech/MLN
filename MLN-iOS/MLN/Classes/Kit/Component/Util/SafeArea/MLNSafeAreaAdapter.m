//
//  MLNSafeAreaAdapter.m
//  MLN
//
//  Created by MoMo on 2019/12/20.
//

#import "MLNSafeAreaAdapter.h"
#import "MLNEntityExporterMacro.h"

@interface MLNSafeAreaAdapter ()

@property (nonatomic, copy) void(^updateInsetsCallback)(void);

@end
@implementation MLNSafeAreaAdapter

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

LUA_EXPORT_BEGIN(MLNSafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsTop, "setInsetsTop:", "insetsTop", MLNSafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsBottom, "setInsetsBottom:", "insetsBottom", MLNSafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsLeft, "setInsetsLeft:", "insetsLeft", MLNSafeAreaAdapter)
LUA_EXPORT_PROPERTY(insetsRight, "setInsetsRight", "insetsRight", MLNSafeAreaAdapter)
LUA_EXPORT_END(MLNSafeAreaAdapter, SafeAreaAdapter, NO, NULL, NULL)

@end
