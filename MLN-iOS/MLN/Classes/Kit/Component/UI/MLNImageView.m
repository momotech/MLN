//
//  MLNImageView.m
//
//
//  Created by MoMo on 2018/7/6.
//

#import "MLNImageView.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNBlock.h"
#import "MLNNinePatchImageFactory.h"
#import "MLNBeforeWaitingTask.h"
#import "MLNLayoutNode.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNGaussEffectHandler.h"
#import "MLNCornerImageLoader.h"

//高斯模糊，值范围，0 ~ 25
#define MLN_BlurScope 25.0f
//图片高斯模糊转换系数
#define MLN_BlurScopeConvertScale 4.0

@interface MLNImageView()

@property (nonatomic, assign) CGFloat blurValue;
@property (nonatomic, assign) BOOL processImage;
@property (nonatomic, weak) UIToolbar *effectView;
@property (nonatomic, copy) NSString *nineImageName;
@property (nonatomic, assign) BOOL synchronziedSetNineImage;
@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;
@property (nonatomic, assign) MLNImageViewMode imageViewMode;
@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, strong) UIImage *rawImage;
@end

@implementation MLNImageView

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectZero]){
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.imageContentMode = UIViewContentModeScaleAspectFit;
        self.imageViewMode = MLNImageViewModeNone;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)lua_addClick:(MLNBlock *)clickCallback
{
    [super lua_addClick:clickCallback];
}

- (void)lua_addTouch:(MLNBlock *)touchCallBack
{
    [super lua_addTouch:touchCallBack];
}

- (void)lua_addLongPress:(MLNBlock *)longPressCallback
{
    [super lua_addLongPress:longPressCallback];
}

- (void)setImage:(UIImage *)image
{
    image = [self convertToBlurImageIfNeed:image];
    [super setImage:image];
    [self.lua_node needLayoutAndSpread];
}

- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return self.image ? self.image.size : CGSizeZero;
}

- (void)checkContentMode
{
    switch (_imageViewMode) {
        case MLNImageViewModeNine:
            break;
        default:
            if (self.imageContentMode != self.contentMode) {
                self.contentMode = self.imageContentMode;
            }
            break;
    }
}

- (void)setImageViewMode:(MLNImageViewMode)imageViewMode
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
    return [MLNGaussEffectHandler coreBlurImage:image withBlurValue:_blurValue * MLN_BlurScopeConvertScale];
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
    self.effectView.alpha = blurValue / MLN_BlurScope;
    [self mln_pushLazyTask:self.lazyTask];
}


#pragma mark - Export Methods
- (void)lua_setImageWith:(nonnull NSString *)imageName
{
    self.imageViewMode = MLNImageViewModeNone;
    if (!stringNotEmpty(imageName)) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setImageWithPath:)], @"-[imageLoder imageView:path:] was not found!");
    [imageLoder imageView:self setImageWithPath:imageName];
}

- (void)lua_setImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString *)placeHolder
{
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:)], @"-[imageLoder imageView:path:placeHolderImage:] was not found!");
    [imageLoder imageView:self setImageWithPath:imageName placeHolderImage:placeHolder];
}

- (void)lua_setImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString *)placeHolder callback:(MLNBlock *)callback
{
    self.imageViewMode = MLNImageViewModeNone;
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    MLNCheckTypeAndNilValue(callback, @"callback", [MLNBlock class]);
    id<MLNImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:completed:)], @"-[imageLoder imageView:placeHolderImage:completed:] was not found!");
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

- (void)lua_setCornerImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString*)placeHolder cornerRadius:(NSInteger)radius direction:(MLNRectCorner)direction
{
    self.imageViewMode = MLNImageViewModeNone;
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoder respondsToSelector:@selector(imageView:setCornerImageWith:placeHolderImage:cornerRadius:dircetion:)], @"-[imageLoder imageView:setCornerImageWith:placeHolderImage:cornerRadius:direction:] was not found!");
    if ([imageLoder respondsToSelector:@selector(imageView:setCornerImageWith:placeHolderImage:cornerRadius:dircetion:)]) {
        [imageLoder imageView:self setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
    } else {
        [MLNCornerImageLoader imageView:self setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
    }
    
}

- (void)lua_setNineImageWith:(nonnull NSString *)imageName synchronized:(BOOL)synchronzied
{
    _nineImageName = imageName;
    _synchronziedSetNineImage = synchronzied;
    if (!stringNotEmpty(imageName)) {
        self.image = nil;
        return;
    }
    
    [self mln_pushLazyTask:self.lazyTask];
}

- (void)mln_in_setNineImageWith:(nonnull NSString *)imageName synchronized:(BOOL)synchronzied
{
    if (!stringNotEmpty(imageName)) {
        return;
    }
    if ([imageName rangeOfString:@".9"].location == NSNotFound && [imageName rangeOfString:@".png"].location == NSNotFound) {
        imageName = [NSString stringWithFormat:@"%@.9",imageName];
    }
    self.imageViewMode = MLNImageViewModeNine;
    id<MLNImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    if ([imageLoder respondsToSelector:@selector(imageView:setNineImageWithPath:synchronized:)]) {
        [imageLoder imageView:self setNineImageWithPath:imageName synchronized:synchronzied];
        return;
    }
    MLNKitLuaAssert([imageLoder respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoder view:loadImageWithPath:completed:] was not found!");
    [imageLoder view:self loadImageWithPath:imageName completed:^(UIImage *image, NSError *error, NSString *imagePath) {
        if (image) {
            CGSize imgViewSize = self.frame.size;
            if (!synchronzied) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resizedImage = [MLNNinePatchImageFactory mln_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setNineImageCheckContentMode:resizedImage];
                    });
                });
            } else {
                UIImage *resizedImage = [MLNNinePatchImageFactory mln_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                [self setNineImageCheckContentMode:resizedImage];
            }
        } else {
            self.image = nil;
        }
    }];
}

- (void)lua_startAnimation:(NSArray <NSString *> *)urlArray duration:(CGFloat)duration repeat:(BOOL)repeat
{
    self.imageViewMode = MLNImageViewModeNone;
    MLNCheckTypeAndNilValue(urlArray, @"Array", [NSMutableArray class])
    if (!(urlArray && urlArray.count > 0)) {
        return;
    }
    id<MLNImageLoaderProtocol> imageLoder = self.imageLoader;
    MLNKitLuaAssert(imageLoder, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoder respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoder view:loadImageWithPath:completed:] was not found!");
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
            MLNKitLuaAssert(NO, @"images: %@ download failed!", failImageArray);
        }
    });
}

- (void)lua_setLazyLoad:(BOOL)lazyLoad
{
    //@note the special feature of Android.
}

- (BOOL)lua_lazyLoad
{
    //@note the special feature of Android.
    return NO;
}


- (void)lua_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    MLNKitLuaAssert(NO, @"ImageView does not support padding!");
}

- (void)lua_setBlurValue:(CGFloat)blurValue processImage:(BOOL)processImage
{
    blurValue = blurValue <= 0.0? 0.0f : blurValue;
    blurValue = blurValue > MLN_BlurScope? MLN_BlurScope : blurValue;
    _processImage = processImage;
    if (processImage) {
        [self checkProcessImageWithBlurValue:blurValue];
    } else {
        [self checkEffectViewWithBlurValue:blurValue];
    }
}

- (void)lua_changedLayout
{
    [super lua_changedLayout];
    if (_blurValue > 0) {
        [self mln_pushLazyTask:self.lazyTask];
    }
}

- (void)lua_setContentMode:(UIViewContentMode)contentMode
{
    MLNKitLuaAssert(contentMode != UIViewContentModeCenter, @"ContentMode.CENTER is deprecated");
    self.imageContentMode = contentMode;
    [self checkContentMode];
}

- (UIViewContentMode)lua_getContentMode
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

- (MLNBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            if (sself.blurValue > 0 && !sself.processImage) {
                sself.effectView.frame = sself.bounds;
            }
            if (sself.nineImageName.length > 0) {
                [sself mln_in_setNineImageWith:sself.nineImageName synchronized:sself.synchronziedSetNineImage];
            }
        }];
    }
    return _lazyTask;
}

- (id<MLNImageLoaderProtocol>)imageLoader
{
    return MLN_KIT_INSTANCE(self.mln_luaCore).instanceHandlersManager.imageLoader;
}

#pragma mark - Override

- (void)lua_addSubview:(UIView *)view
{
    MLNKitLuaAssert(NO, @"Not found \"addView\" method in ImageView, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNKitLuaAssert(NO, @"Not found \"insertView\" method in ImageView, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method in ImageView, just continar of View has it!");
}

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

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNImageView)
LUA_EXPORT_VIEW_PROPERTY(contentMode, "lua_setContentMode:","contentMode", MLNImageView)
LUA_EXPORT_VIEW_PROPERTY(lazyLoad, "lua_setLazyLoad:","lua_lazyLoad", MLNImageView)
LUA_EXPORT_VIEW_METHOD(startAnimationImages, "lua_startAnimation:duration:repeat:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(stopAnimationImages, "stopAnimating", MLNImageView)
LUA_EXPORT_VIEW_METHOD(isAnimating, "isAnimating", MLNImageView)
LUA_EXPORT_VIEW_METHOD(image, "lua_setImageWith:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setImageUrl, "lua_setImageWith:placeHolderImage:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setCornerImage, "lua_setCornerImageWith:placeHolderImage:cornerRadius:direction:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setImageWithCallback, "lua_setImageWith:placeHolderImage:callback:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setNineImage, "lua_setNineImageWith:synchronized:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(blurImage, "lua_setBlurValue:processImage:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(addShadow, "lua_addShadow:shadowOffset:shadowRadius:shadowOpacity:isOval:", MLNImageView)
LUA_EXPORT_VIEW_END(MLNImageView, ImageView, YES, "MLNView", NULL)

@end
