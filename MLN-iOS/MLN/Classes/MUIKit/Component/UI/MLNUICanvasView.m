//
//  MLNUICanvasView.m
//
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUICanvasView.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUIKit.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUIBeforeWaitingTask.h"
#import "MLNUIShapeContext.h"
#import "MLNUIBlock.h"


@interface MLNUICanvasView()

@property (nonatomic, strong) MLNUIBlock *mln_drawRectCallback;
@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;
@property (nonatomic, strong) MLNUIShapeContext *context;

@end

@implementation MLNUICanvasView


- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself drawStart];
        }];
    }
    return _lazyTask;
}

- (MLNUIShapeContext *)context
{
    if (!_context) {
        _context = [[MLNUIShapeContext alloc] initWithLuaCore:self.mln_luaCore TargetView:self];
    }
    return _context;
}

- (void)drawStart
{
    if (_mln_drawRectCallback) {
        [_context cleanShapes];
        [_mln_drawRectCallback addObjArgument:self.context];
        [_mln_drawRectCallback callIfCan];
    }
}

- (void)dealloc4Lua
{
    _context = nil;
}

#pragma mark - Draw
- (void)lua_setDrawCallback:(MLNUIBlock *)block
{
    self.mln_drawRectCallback = block;
    [self mln_pushLazyTask:self.lazyTask];
}

- (void)lua_refresh
{
    if (self.mln_drawRectCallback) {
        [self mln_pushLazyTask:self.lazyTask];
    }
}

#pragma mark - Overrid For Lua
- (BOOL)lua_canClick
{
    return YES;
}

- (BOOL)lua_canLongPress
{
    return YES;
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

- (void)lua_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUICanvasView)
LUA_EXPORT_VIEW_METHOD(onDraw, "lua_setDrawCallback:", MLNUICanvasView)
LUA_EXPORT_VIEW_METHOD(refresh, "lua_refresh", MLNUICanvasView)
LUA_EXPORT_VIEW_END(MLNUICanvasView, CanvasView, YES, "MLNUIView", NULL)

@end
