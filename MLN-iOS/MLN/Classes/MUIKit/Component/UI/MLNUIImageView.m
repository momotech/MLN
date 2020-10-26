//
//  MLNUIImageView.m
//
//
//  Created by MoMo on 2018/7/6.
//

#import "MLNUIImageView.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIBlock.h"
#import "MLNUINinePatchImageFactory.h"
#import "MLNUIBeforeWaitingTask.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIGaussEffectHandler.h"
#import "MLNUICornerImageLoader.h"

//高斯模糊，值范围，0 ~ 25
#define MLNUI_BlurScope 25.0f
//图片高斯模糊转换系数
#define MLNUI_BlurScopeConvertScale 4.0

@interface MLNUIImageView()

@property (nonatomic, assign) CGFloat blurValue;
@property (nonatomic, assign) BOOL processImage;
@property (nonatomic, weak) UIToolbar *effectView;
@property (nonatomic, copy) NSString *nineImageName;
@property (nonatomic, assign) BOOL synchronziedSetNineImage;
@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;
@property (nonatomic, assign) MLNUIImageViewMode imageViewMode;
@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, assign) BOOL enable;
@end

@implementation MLNUIImageView

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectZero]){
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.imageContentMode = UIViewContentModeScaleAspectFit;
        self.imageViewMode = MLNUIImageViewModeNone;
        self.clipsToBounds = YES;
        _enable = YES;
    }
    return self;
}

- (BOOL)luaui_enable
{
    return self.enable;
}

- (void)setLuaui_enable:(BOOL)luaui_enable
{
    [super setLuaui_enable:luaui_enable];
    self.enable = luaui_enable;
}

- (void)luaui_addClick:(MLNUIBlock *)clickCallback
{
    [super luaui_addClick:clickCallback];
    self.userInteractionEnabled = clickCallback != nil;
}

- (void)luaui_addTouch:(MLNUIBlock *)touchCallBack
{
    [super luaui_addTouch:touchCallBack];
    self.userInteractionEnabled = touchCallBack != nil;
}

- (void)luaui_addLongPress:(MLNUIBlock *)longPressCallback
{
    [super luaui_addLongPress:longPressCallback];
    self.userInteractionEnabled = longPressCallback != nil;
}

- (void)setImage:(UIImage *)image
{
    image = [self convertToBlurImageIfNeed:image];
    [super setImage:image];
    [self mlnui_markNeedsLayout];
}

- (void)checkContentMode
{
    switch (_imageViewMode) {
        case MLNUIImageViewModeNine:
            break;
        default:
            if (self.imageContentMode != self.contentMode) {
                self.contentMode = self.imageContentMode;
            }
            break;
    }
}

- (void)setImageViewMode:(MLNUIImageViewMode)imageViewMode
{
    _imageViewMode = imageViewMode;
    [self checkContentMode];
}

- (void)setNineImageCheckContentMode:(UIImage *)image
{
    self.image = nil;
    if (self.contentMode != UIViewContentModeScaleToFill) {
        self.contentMode = UIViewContentModeScaleToFill;
    }
    self.image = image;
}

#pragma mark - Blur Image
- (UIImage *)convertToBlurImageIfNeed:(UIImage *)image
{
    UIImage *newImage = image;
    //    当没有高斯模糊值且不需要处理图片模糊度时，不需要处理
    if (_blurValue == 0 || !_processImage || image == nil) {
        self.rawImage = nil;
        return newImage;
    }
    self.rawImage = image;
    return [MLNUIGaussEffectHandler coreBlurImage:image withBlurValue:_blurValue * MLNUI_BlurScopeConvertScale];
}

- (void)checkProcessImageWithBlurValue:(CGFloat)blurValue
{
    if (self.rawImage != nil && self.rawImage != self.image && _blurValue == blurValue ) {
        return;
    }
    _effectView.hidden = YES;
    _blurValue = blurValue;
    [self setImage:self.image];
}

- (void)checkEffectViewWithBlurValue:(CGFloat)blurValue
{
    _blurValue = blurValue;
    if (self.rawImage) {
        self.image = self.rawImage;
        self.rawImage = nil;
    }
    if (blurValue <= 0) {
        _effectView.hidden = YES;
        return;
    }
    if (self.rawImage) {
        [self setImage:self.rawImage];
    }
    self.effectView.hidden = NO;
    self.effectView.alpha = blurValue / MLNUI_BlurScope;
    [self mlnui_pushLazyTask:self.lazyTask];
}


#pragma mark - Export Methods
- (void)luaui_setImageWith:(nonnull NSString *)imageName
{
    self.imageViewMode = MLNUIImageViewModeNone;
    if (!stringNotEmpty(imageName)) {
        self.image = nil;
        return;
    }
    id<MLNUIImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNUIKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setImageWithPath:)], @"-[imageLoder imageView:path:] was not found!");
    [imageLoder imageView:self setImageWithPath:imageName];
}

- (void)luaui_setImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString *)placeHolder
{
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNUIImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNUIKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:)], @"-[imageLoder imageView:path:placeHolderImage:] was not found!");
    [imageLoder imageView:self setImageWithPath:imageName placeHolderImage:placeHolder];
}

- (void)luaui_setImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString *)placeHolder callback:(MLNUIBlock *)callback
{
    self.imageViewMode = MLNUIImageViewModeNone;
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    MLNUICheckTypeAndNilValue(callback, @"callback", [MLNUIBlock class]);
    id<MLNUIImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNUIKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:completed:)], @"-[imageLoder imageView:placeHolderImage:completed:] was not found!");
    [imageLoder imageView:self setImageWithPath:imageName placeHolderImage:placeHolder completed:^(UIImage *image, NSError *error, NSString *imagePath) {
        doInMainQueue(if (callback) {
            BOOL success = YES;
            NSString *msg = nil;
            if (error) {
                success = NO;
                msg = [error localizedDescription];
            }
            [callback addBOOLArgument:success];
            [callback addObjArgument:msg];
            [callback addStringArgument:imagePath];
            [callback callIfCan];
        })
    }];
}

- (void)luaui_setCornerImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString*)placeHolder cornerRadius:(NSInteger)radius direction:(MLNUIRectCorner)direction
{
    self.imageViewMode = MLNUIImageViewModeNone;
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNUIImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNUIKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setCornerImageWith:placeHolderImage:cornerRadius:dircetion:)], @"-[imageLoder imageView:setCornerImageWith:placeHolderImage:cornerRadius:direction:] was not found!");
    if ([imageLoder respondsToSelector:@selector(imageView:setCornerImageWith:placeHolderImage:cornerRadius:dircetion:)]) {
        [imageLoder imageView:self setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
    } else {
        [MLNUICornerImageLoader imageView:self setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
    }
    
}

- (void)luaui_setNineImageWith:(nonnull NSString *)imageName
{
    _nineImageName = imageName;
    _synchronziedSetNineImage = true;
    if (!stringNotEmpty(imageName)) {
        self.image = nil;
        return;
    }
    
    [self mlnui_pushLazyTask:self.lazyTask];
}

- (void)mlnui_in_setNineImageWith:(nonnull NSString *)imageName synchronized:(BOOL)synchronzied
{
    if (!stringNotEmpty(imageName)) {
        return;
    }
    if ([imageName rangeOfString:@".9"].location == NSNotFound && [imageName rangeOfString:@".png"].location == NSNotFound) {
        imageName = [NSString stringWithFormat:@"%@.9",imageName];
    }
    self.imageViewMode = MLNUIImageViewModeNine;
    id<MLNUIImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNUIKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    if ([imageLoder respondsToSelector:@selector(imageView:setNineImageWithPath:synchronized:)]) {
        [imageLoder imageView:self setNineImageWithPath:imageName synchronized:synchronzied];
        return;
    }
    MLNUIKitLuaAssert([imageLoder respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoder view:loadImageWithPath:completed:] was not found!");
    [imageLoder view:self loadImageWithPath:imageName completed:^(UIImage *image, NSError *error, NSString *imagePath) {
        if (image) {
            CGSize imgViewSize = self.frame.size;
            if (!synchronzied) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resizedImage = [MLNUINinePatchImageFactory mlnui_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setNineImageCheckContentMode:resizedImage];
                    });
                });
            } else {
                UIImage *resizedImage = [MLNUINinePatchImageFactory mlnui_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                [self setNineImageCheckContentMode:resizedImage];
            }
        } else {
            self.image = nil;
        }
    }];
}

- (void)luaui_startAnimation:(NSArray <NSString *> *)urlArray duration:(CGFloat)duration repeat:(BOOL)repeat
{
    self.imageViewMode = MLNUIImageViewModeNone;
    MLNUICheckTypeAndNilValue(urlArray, @"Array", [NSMutableArray class])
    if (!(urlArray && urlArray.count > 0)) {
        return;
    }
    id<MLNUIImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNUIKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNUIKitLuaAssert([imageLoder respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoder view:loadImageWithPath:completed:] was not found!");
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:urlArray.count];
    NSMutableArray *failImageArray = [NSMutableArray arrayWithCapacity:urlArray.count];
    for (NSUInteger i = 0; i < urlArray.count; i++) {
        [imageArray addObject:[NSNull null]];
        [failImageArray addObject:[urlArray objectAtIndex:i]];
    }
    dispatch_group_t imagesGroup = dispatch_group_create();
    for (NSUInteger i = 0; i < urlArray.count; i++) {
        NSString *urlStr = [urlArray objectAtIndex:i];
        dispatch_group_enter(imagesGroup);
        [imageLoder view:self loadImageWithPath:urlStr completed:^(UIImage *image, NSError *error, NSString *imagePath) {
            doInMainQueue(if (image) {
                [imageArray replaceObjectAtIndex:i withObject:image];
                [failImageArray removeObject:urlStr];
            }
                          dispatch_group_leave(imagesGroup);)
        }];
    }
    dispatch_group_notify(imagesGroup, dispatch_get_main_queue(), ^{
        if (failImageArray.count <= 0) {
            [self setImage:imageArray.lastObject];
            [self setAnimationImages:imageArray];
            [self setAnimationDuration:duration];
            [self setAnimationRepeatCount:repeat?0:1];
            [self startAnimating];
        } else {
            MLNUIKitLuaAssert(NO, @"images: %@ download failed!", failImageArray);
        }
    });
}

- (void)luaui_setLazyLoad:(BOOL)lazyLoad
{
    //@note the special feature of Android.
}

- (BOOL)luaui_lazyLoad
{
    //@note the special feature of Android.
    return NO;
}


- (void)luaui_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    MLNUIKitLuaAssert(NO, @"ImageView does not support padding!");
}

- (void)setLuaui_paddingTop:(CGFloat)luaui_paddingTop {
    MLNUIKitLuaAssert(NO, @"ImageView does not support padding!");
}

- (void)setLuaui_paddingLeft:(CGFloat)luaui_paddingLeft {
    MLNUIKitLuaAssert(NO, @"ImageView does not support padding!");
}

- (void)setLuaui_paddingRight:(CGFloat)luaui_paddingRight {
    MLNUIKitLuaAssert(NO, @"ImageView does not support padding!");
}

- (void)setLuaui_paddingBottom:(CGFloat)luaui_paddingBottom {
    MLNUIKitLuaAssert(NO, @"ImageView does not support padding!");
}

- (void)luaui_setBlurValue:(CGFloat)blurValue processImage:(BOOL)processImage
{
    blurValue = blurValue <= 0.0? 0.0f : blurValue;
    blurValue = blurValue > MLNUI_BlurScope? MLNUI_BlurScope : blurValue;
    _processImage = processImage;
    if (processImage) {
        [self checkProcessImageWithBlurValue:blurValue];
    } else {
        [self checkEffectViewWithBlurValue:blurValue];
    }
}

- (void)mlnui_layoutDidChange {
    [super mlnui_layoutDidChange];
    if (_blurValue > 0) {
        [self mlnui_pushLazyTask:self.lazyTask];
    }
}

- (void)luaui_setContentMode:(UIViewContentMode)contentMode
{
    MLNUIKitLuaAssert(contentMode != UIViewContentModeCenter, @"ContentMode.CENTER is deprecated");
    self.imageContentMode = contentMode;
    [self checkContentMode];
}

- (UIViewContentMode)luaui_getContentMode
{
    return self.imageContentMode;
}

#pragma - mark getter & setter
- (UIToolbar *)effectView
{
    if (!_effectView) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.barStyle = UIBarStyleDefault;
        [self addSubview:toolbar];
        _effectView = toolbar;
    }
    return _effectView;
}

- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            if (sself.blurValue > 0 && !sself.processImage) {
                sself.effectView.frame = sself.bounds;
            }
            if (sself.nineImageName.length > 0) {
                [sself mlnui_in_setNineImageWith:sself.nineImageName synchronized:sself.synchronziedSetNineImage];
            }
        }];
    }
    return _lazyTask;
}

- (id<MLNUIImageLoaderProtocol>)imageLoader
{
    return MLNUI_KIT_INSTANCE(self.mlnui_luaCore).instanceHandlersManager.imageLoader;
}

#pragma mark - Override

- (CGSize)mlnui_sizeThatFits:(CGSize)size {
    return self.image ? self.image.size : CGSizeZero;
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method in ImageView, just continar of View has it!");
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method in ImageView, just continar of View has it!");
}

- (void)luaui_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method in ImageView, just continar of View has it!");
}

- (BOOL)luaui_canClick
{
    return YES;
}

- (BOOL)luaui_canLongPress
{
    return YES;
}

- (BOOL)luaui_canPinch {
    return YES;
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUIImageView)
LUAUI_EXPORT_VIEW_PROPERTY(contentMode, "luaui_setContentMode:","contentMode", MLNUIImageView)
LUAUI_EXPORT_VIEW_PROPERTY(lazyLoad, "luaui_setLazyLoad:","luaui_lazyLoad", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(startAnimationImages, "luaui_startAnimation:duration:repeat:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(stopAnimationImages, "stopAnimating", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(isAnimating, "isAnimating", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(image, "luaui_setImageWith:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(setImageUrl, "luaui_setImageWith:placeHolderImage:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(setCornerImage, "luaui_setCornerImageWith:placeHolderImage:cornerRadius:direction:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(setImageWithCallback, "luaui_setImageWith:placeHolderImage:callback:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(setNineImage, "luaui_setNineImageWith:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(blurImage, "luaui_setBlurValue:processImage:", MLNUIImageView)
LUAUI_EXPORT_VIEW_METHOD(addShadow, "luaui_addShadow:shadowOffset:shadowRadius:shadowOpacity:isOval:", MLNUIImageView)
LUAUI_EXPORT_VIEW_END(MLNUIImageView, ImageView, YES, "MLNUIView", NULL)

@end
