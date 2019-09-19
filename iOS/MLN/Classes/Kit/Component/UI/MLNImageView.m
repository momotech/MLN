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

//高斯模糊，值范围，0 ~ 25
#define BlurScope 25.0f

@interface MLNImageView()

@property (nonatomic, assign) CGFloat blurValue;
@property (nonatomic, weak) UIToolbar *effectView;
@property (nonatomic, copy) NSString *nineImageName;
@property (nonatomic, assign) BOOL synchronziedSetNineImage;
@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;

@end

@implementation MLNImageView

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectZero]){
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    [self.lua_node needLayoutAndSpread];
}

- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.image) {
        maxWidth -= self.lua_paddingLeft + self.lua_paddingRight;
        maxHeight -= self.lua_paddingTop + self.lua_paddingBottom;
        CGSize size = self.image.size;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        size.width = size.width + self.lua_paddingLeft + self.lua_paddingRight;
        size.height = size.height + self.lua_paddingTop + self.lua_paddingBottom;
        return size;
    }
    return CGSizeZero;
}

#pragma mark - Export Methods
- (void)lua_setImageWith:(nonnull NSString *)imageName
{
    if (!stringNotEmpty(imageName)) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoader = self.imageLoader;
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoader respondsToSelector:@selector(imageView:setImageWithPath:)], @"-[imageLoader imageView:path:] was not found!");
#if defined(DEBUG)
    if ([imageLoader respondsToSelector:@selector(imageView:setImageWithPath:)]) {
        [imageLoader imageView:self setImageWithPath:imageName];
    }
#else
    [imageLoader imageView:self setImageWithPath:imageName];
#endif
}

- (void)lua_setImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString *)placeHolder
{
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoader = self.imageLoader;
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoader respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:)], @"-[imageLoader imageView:path:placeHolderImage:] was not found!");
#if defined(DEBUG)
    if ([imageLoader respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:)]) {
        [imageLoader imageView:self setImageWithPath:imageName placeHolderImage:placeHolder];
    }
#else
    [imageLoader imageView:self setImageWithPath:imageName placeHolderImage:placeHolder];
#endif
}

- (void)lua_setImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString *)placeHolder callback:(MLNBlock *)callback
{
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoader = self.imageLoader;
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoader respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:completed:)], @"-[imageLoader imageView:placeHolderImage:completed:] was not found!");
#if defined(DEBUG)
    if ([imageLoader respondsToSelector:@selector(imageView:setImageWithPath:placeHolderImage:completed:)]) {
        [imageLoader imageView:self setImageWithPath:imageName placeHolderImage:placeHolder completed:^(UIImage *image, NSError *error, NSString *imagePath) {
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
#else
    [imageLoader imageView:self setImageWithPath:imageName placeHolderImage:placeHolder completed:^(UIImage *image, NSError *error, NSString *imagePath) {
        doInMainQueue(if (callback) {
            BOOL success = YES;
            NSString *msg = nil;
            if (error) {
                success = NO;
                msg = [error localizedDescription];
            }
            [callback setBOOLParam:success];
            [callback setObjParam:msg];
            [callback setStringParam:imagePath];
            [callback callIfCan];
        })
    }];
#endif
    
}

- (void)lua_setCornerImageWith:(nonnull NSString *)imageName placeHolderImage:(NSString*)placeHolder cornerRadius:(NSInteger)radius direction:(MLNRectCorner)direction
{
    if ((!stringNotEmpty(imageName) && !stringNotEmpty(placeHolder))) {
        self.image = nil;
        return;
    }
    id<MLNImageLoaderProtocol> imageLoader = self.imageLoader;
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoader respondsToSelector:@selector(imageView:setCornerImageWith:placeHolderImage:cornerRadius:dircetion:)], @"-[imageLoader imageView:setCornerImageWith:placeHolderImage:cornerRadius:direction:] was not found!");
#if defined(DEBUG)
    if ([imageLoader respondsToSelector:@selector(imageView:setCornerImageWith:placeHolderImage:cornerRadius:dircetion:)]) {
        [imageLoader imageView:self setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
    }
#else
    [imageLoader imageView:self setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
#endif
}

- (void)lua_setNineImageWith:(nonnull NSString *)imageName synchronized:(BOOL)synchronzied
{
    _nineImageName = imageName;
    _synchronziedSetNineImage = synchronzied;
    if (!stringNotEmpty(imageName)) {
        self.image = nil;
        return;
    }
    [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
}

- (void)mln_in_setNineImageWith:(nonnull NSString *)imageName synchronized:(BOOL)synchronzied
{
    if (!stringNotEmpty(imageName)) {
        return;
    }
    if ([imageName rangeOfString:@".9"].location == NSNotFound) {
        [self lua_setImageWith:imageName];
        return;
    }
    id<MLNImageLoaderProtocol> imageLoader = self.imageLoader;
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    if ([imageLoader respondsToSelector:@selector(imageView:setNineImageWithPath:synchronized:)]) {
        [imageLoader imageView:self setNineImageWithPath:imageName synchronized:synchronzied];
        return;
    }
    self.contentMode = UIViewContentModeScaleToFill;
    MLNKitLuaAssert([imageLoader respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoader view:loadImageWithPath:completed:] was not found!");
#if defined(DEBUG)
    if ([imageLoader respondsToSelector:@selector(view:loadImageWithPath:completed:)]) {
        [imageLoader view:self loadImageWithPath:imageName completed:^(UIImage *image, NSError *error, NSString *imagePath) {
            if (image) {
                CGSize imgViewSize = self.frame.size;
                if (!synchronzied) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage* resizedImage = [MLNNinePatchImageFactory mln_in_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = resizedImage;
                        });
                    });
                } else {
                    self.image = [MLNNinePatchImageFactory mln_in_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                }
            } else {
                self.image = nil;
            }
        }];
    }
#else
    [imageLoader loadImageWithPath:imageName completed:^(UIImage *image, NSError *error, NSString *imagePath) {
        if (image) {
            CGSize imgViewSize = self.frame.size;
            if (!synchronzied) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage* resizedImage = [MLNNinePatchImageFactory mln_in_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = resizedImage;
                    });
                });
            } else {
                self.image = [MLNNinePatchImageFactory mln_in_createResizableNinePatchImage:image imgViewSize:imgViewSize];
            }
        } else {
            self.image = nil;
        }
    }];
#endif
    
}

- (void)lua_startAnimation:(NSArray <NSString *> *)urlArray duration:(CGFloat)duration repeat:(BOOL)repeat
{
    MLNCheckTypeAndNilValue(urlArray, @"Array", [NSMutableArray class])
    if (!(urlArray && urlArray.count > 0)) {
        return;
    }
    id<MLNImageLoaderProtocol> imageLoader = self.imageLoader;
    MLNKitLuaAssert(imageLoader, @"The image delegate must not be nil!");
    MLNKitLuaAssert([imageLoader respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoader loadImageWithPath:completed:] was not found!");
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:urlArray.count];
    dispatch_group_t imagesGroup = dispatch_group_create();
    for (NSString *urlStr in urlArray) {
        dispatch_group_enter(imagesGroup);
        [imageLoader view:self loadImageWithPath:urlStr completed:^(UIImage *image, NSError *error, NSString *imagePath) {
            if (image) {
                [imageArray addObject:image];
            }
            dispatch_group_leave(imagesGroup);
        }];
    }
    dispatch_group_notify(imagesGroup, dispatch_get_main_queue(), ^{
        if (imageArray.count == urlArray.count) {
            [self setImage:imageArray.lastObject];
            [self setAnimationImages:imageArray];
            [self setAnimationDuration:duration];
            [self setAnimationRepeatCount:repeat?0:1];
            [self startAnimating];
        } else {
            MLNKitLuaError(@"Some images download failed!");
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

- (void)lua_setBlurValue:(CGFloat)blurValue
{
    if (blurValue <= 0) {
        self.effectView.hidden = YES;
        return;
    }
    self.effectView.hidden = NO;
    self.effectView.alpha = blurValue / BlurScope;
    _blurValue = blurValue;
    [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
}

- (void)lua_changedLayout
{
    [super lua_changedLayout];
    if (_blurValue > 0) {
        [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
    }
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
            if (sself.blurValue > 0) {
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
LUA_EXPORT_VIEW_PROPERTY(contentMode, "setContentMode:","contentMode", MLNImageView)
LUA_EXPORT_VIEW_PROPERTY(lazyLoad, "lua_setLazyLoad:","lua_lazyLoad", MLNImageView)
LUA_EXPORT_VIEW_METHOD(startAnimationImages, "lua_startAnimation:duration:repeat:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(stopAnimationImages, "stopAnimating", MLNImageView)
LUA_EXPORT_VIEW_METHOD(isAnimating, "isAnimating", MLNImageView)
LUA_EXPORT_VIEW_METHOD(image, "lua_setImageWith:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setImageUrl, "lua_setImageWith:placeHolderImage:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setCornerImage, "lua_setCornerImageWith:placeHolderImage:cornerRadius:direction:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setImageWithCallback, "lua_setImageWith:placeHolderImage:callback:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(setNineImage, "lua_setNineImageWith:synchronized:", MLNImageView)
LUA_EXPORT_VIEW_METHOD(blurImage, "lua_setBlurValue:", MLNImageView)
LUA_EXPORT_VIEW_END(MLNImageView, ImageView, YES, "MLNView", NULL)

@end
