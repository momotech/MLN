//
//  MLNUIButton.m
//  
//
//  Created by MoMo on 2018/7/10.
//

#import "MLNUIButton.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIImageLoaderProtocol.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIBlock.h"
#import "MLNUIKitInstanceHandlersManager.h"

@interface MLNUIButton()

@end

@implementation MLNUIButton
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)lua_addClick:(MLNUIBlock *)clickCallback
{
    if (!self.mln_tapClickBlock) {
        [self addTarget:self action:@selector(buttonCallBack) forControlEvents:UIControlEventTouchUpInside];
    }
    self.mln_tapClickBlock = clickCallback;
}

- (void)buttonCallBack
{
    if (self.mln_tapClickBlock) {
        [self.mln_tapClickBlock  callIfCan];
    }
}

- (void)lua_setImage:(NSString *)imageSrc press:(NSString *)press
{
    MLNUICheckStringTypeAndNilValue(imageSrc)
    [self lua_setImage:imageSrc forState:UIControlStateNormal];
    [self lua_setImage:press forState:UIControlStateHighlighted];
}

- (void)lua_setImage:(NSString *)imageSrc forState:(UIControlState)state
{
    MLNUICheckStringTypeAndNilValue(imageSrc)
    id<MLNUIImageLoaderProtocol> imageLoader = [self imageLoader];
    MLNUIKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoader  respondsToSelector:@selector(button:setImageWithPath:forState:)], @"-[imageLoader button:setImageWithPath:forState:] was not found!");
    [imageLoader button:self setImageWithPath:imageSrc forState:state];
}

- (void)lua_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [super lua_setPaddingWithTop:top right:right bottom:bottom left:left];
    self.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (id<MLNUIImageLoaderProtocol>)imageLoader
{
    return MLNUI_KIT_INSTANCE(self.mln_luaCore).instanceHandlersManager.imageLoader;
}

#pragma mark - Override
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

- (BOOL)lua_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUIButton)
LUA_EXPORT_VIEW_METHOD(setImage, "lua_setImage:press:", MLNUIButton)
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPaddingWithTop:right:bottom:left:", MLNUIButton)
LUA_EXPORT_VIEW_END(MLNUIButton, ImageButton, YES, "MLNUIView", NULL)

@end
