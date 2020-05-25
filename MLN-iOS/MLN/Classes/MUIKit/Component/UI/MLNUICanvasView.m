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

@property (nonatomic, strong) MLNUIBlock *mlnui_drawRectCallback;
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
        _context = [[MLNUIShapeContext alloc] initWithMLNUILuaCore:self.mlnui_luaCore TargetView:self];
    }
    return _context;
}

- (void)drawStart
{
    if (_mlnui_drawRectCallback) {
        [_context cleanShapes];
        [_mlnui_drawRectCallback addObjArgument:self.context];
        [_mlnui_drawRectCallback callIfCan];
    }
}

- (void)dealloc4Lua
{
    _context = nil;
}

#pragma mark - Draw
- (void)luaui_setDrawCallback:(MLNUIBlock *)block
{
    self.mlnui_drawRectCallback = block;
    [self mlnui_pushLazyTask:self.lazyTask];
}

- (void)luaui_refresh
{
    if (self.mlnui_drawRectCallback) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

#pragma mark - Overrid For Lua
- (BOOL)luaui_canClick
{
    return YES;
}

- (BOOL)luaui_canLongPress
{
    return YES;
}

- (BOOL)luaui_layoutEnable
{
    return YES;
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)luaui_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUICanvasView)
LUA_EXPORT_VIEW_METHOD(onDraw, "luaui_setDrawCallback:", MLNUICanvasView)
LUA_EXPORT_VIEW_METHOD(refresh, "luaui_refresh", MLNUICanvasView)
LUA_EXPORT_VIEW_END(MLNUICanvasView, CanvasView, YES, "MLNUIView", NULL)

@end
