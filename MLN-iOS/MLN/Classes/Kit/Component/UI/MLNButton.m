//
//  MLNButton.m
//  
//
//  Created by MoMo on 2018/7/10.
//

#import "MLNButton.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "MLNImageLoaderProtocol.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNBlock.h"
#import "MLNKitInstanceHandlersManager.h"

@interface MLNButton()

@end

@implementation MLNButton
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)lua_addClick:(MLNBlock *)clickCallback
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
    MLNCheckStringTypeAndNilValue(imageSrc)
    [self lua_setImage:imageSrc forState:UIControlStateNormal];
    [self lua_setImage:press forState:UIControlStateHighlighted];
}

- (void)lua_setImage:(NSString *)imageSrc forState:(UIControlState)state
{
    MLNCheckStringTypeAndNilValue(imageSrc)
    id<MLNImageLoaderProtocol> imageLoader = [self imageLoader];
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoader  respondsToSelector:@selector(button:setImageWithPath:forState:)], @"-[imageLoader button:setImageWithPath:forState:] was not found!");
    [imageLoader button:self setImageWithPath:imageSrc forState:state];
}

- (void)lua_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [super lua_setPaddingWithTop:top right:right bottom:bottom left:left];
    self.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (id<MLNImageLoaderProtocol>)imageLoader
{
    return MLN_KIT_INSTANCE(self.mln_luaCore).instanceHandlersManager.imageLoader;
}

#pragma mark - Override
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

- (BOOL)lua_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNButton)
LUA_EXPORT_VIEW_METHOD(setImage, "lua_setImage:press:", MLNButton)
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPaddingWithTop:right:bottom:left:", MLNButton)
LUA_EXPORT_VIEW_END(MLNButton, ImageButton, YES, "MLNView", NULL)

@end
