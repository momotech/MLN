//
//  MLNCanvasView.m
//
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNCanvasView.h"
#import "MLNViewExporterMacro.h"
#import "MLNKitHeader.h"
#import "UIView+MLNKit.h"
#import "MLNLayoutContainerNode.h"
#import "MLNBeforeWaitingTask.h"
#import "MLNShapeContext.h"
#import "MLNBlock.h"


@interface MLNCanvasView()

@property (nonatomic, strong) MLNBlock *mln_drawRectCallback;
@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;
@property (nonatomic, strong) MLNShapeContext *context;

@end

@implementation MLNCanvasView


- (MLNBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself drawStart];
        }];
    }
    return _lazyTask;
}

- (MLNShapeContext *)context
{
    if (!_context) {
        _context = [[MLNShapeContext alloc] initWithLuaCore:self.mln_luaCore TargetView:self];
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
- (void)lua_setDrawCallback:(MLNBlock *)block
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
    MLNKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNCanvasView)
LUA_EXPORT_VIEW_METHOD(onDraw, "lua_setDrawCallback:", MLNCanvasView)
LUA_EXPORT_VIEW_METHOD(refresh, "lua_refresh", MLNCanvasView)
LUA_EXPORT_VIEW_END(MLNCanvasView, CanvasView, YES, "MLNView", NULL)

@end
