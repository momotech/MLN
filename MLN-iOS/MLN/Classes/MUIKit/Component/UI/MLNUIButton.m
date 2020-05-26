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

- (void)luaui_addClick:(MLNUIBlock *)clickCallback
{
    if (!self.mlnui_tapClickBlock) {
        [self addTarget:self action:@selector(buttonCallBack) forControlEvents:UIControlEventTouchUpInside];
    }
    self.mlnui_tapClickBlock = clickCallback;
}

- (void)buttonCallBack
{
    if (self.mlnui_tapClickBlock) {
        [self.mlnui_tapClickBlock  callIfCan];
    }
}

- (void)luaui_setImage:(NSString *)imageSrc press:(NSString *)press
{
    MLNUICheckStringTypeAndNilValue(imageSrc)
    [self luaui_setImage:imageSrc forState:UIControlStateNormal];
    [self luaui_setImage:press forState:UIControlStateHighlighted];
}

- (void)luaui_setImage:(NSString *)imageSrc forState:(UIControlState)state
{
    MLNUICheckStringTypeAndNilValue(imageSrc)
    id<MLNUIImageLoaderProtocol> imageLoader = [self imageLoader];
    MLNUIKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoader  respondsToSelector:@selector(button:setImageWithPath:forState:)], @"-[imageLoader button:setImageWithPath:forState:] was not found!");
    [imageLoader button:self setImageWithPath:imageSrc forState:state];
}

- (void)luaui_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [super luaui_setPaddingWithTop:top right:right bottom:bottom left:left];
    self.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (id<MLNUIImageLoaderProtocol>)imageLoader
{
    return MLNUI_KIT_INSTANCE(self.mlnui_luaCore).instanceHandlersManager.imageLoader;
}

#pragma mark - Override
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

- (BOOL)luaui_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUIButton)
LUAUI_EXPORT_VIEW_METHOD(setImage, "luaui_setImage:press:", MLNUIButton)
LUAUI_EXPORT_VIEW_METHOD(padding, "luaui_setPaddingWithTop:right:bottom:left:", MLNUIButton)
LUAUI_EXPORT_VIEW_END(MLNUIButton, ImageButton, YES, "MLNUIView", NULL)

@end
