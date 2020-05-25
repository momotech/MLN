//
//  MLNUICornerLayerHandler.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNUICornerLayerHandler.h"
#import "MLNUICornerManagerTool.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIRenderContext.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitInstanceConsts.h"

@interface MLNUICornerLayerHandler()

@property (nonatomic, assign) CGFloat realCornerRadius;
@property (nonatomic, assign) CGFloat cornerRadius;

@end

@implementation MLNUICornerLayerHandler

@synthesize targetView = _targetView;
@synthesize needRemake = _needRemake;

- (instancetype)initWithTargetView:(UIView *)view;
{
    if (self = [super init]) {
        _targetView = view;
        _needRemake = NO;
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self addCorner:UIRectCornerAllCorners cornerRadius:cornerRadius];
}

- (void)addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius
{
    [self addCorner:corner cornerRadius:cornerRadius maskColor:nil];
}

- (void)addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius maskColor:(nullable UIColor *)maskColor {
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        _needRemake = YES;
    }
}

- (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner
{
    return _cornerRadius;
}

- (void)clean {
    _cornerRadius = 0.f;
    _realCornerRadius = 0.0f;
    self.targetView.layer.cornerRadius = 0.f;
    _needRemake = NO;
}

- (void)remakeIfNeed {
    CGFloat realCornerRadius = [MLNUICornerManagerTool realCornerRadiusWith:_targetView cornerRadius:_cornerRadius];
    [self setupClipToBounds];
    if (_needRemake || _realCornerRadius != realCornerRadius) {
        _realCornerRadius = realCornerRadius;
        self.targetView.layer.cornerRadius = realCornerRadius;
        _needRemake = NO;
    }
}

- (void)setupClipToBounds
{
    MLNUIRenderContext *context = self.targetView.mln_renderContext;
    BOOL isOpenDefaultClip = NO;
    if ([self.targetView mln_isConvertible]) {
        // 添加Lua强引用
        id<MLNUIEntityExportProtocol> obj = (id<MLNUIEntityExportProtocol>)self.targetView;
        isOpenDefaultClip = [MLNUI_KIT_INSTANCE(obj.mln_luaCore) instanceConsts].defaultCornerClip;
    }
    if (isOpenDefaultClip && !context.didSetClipToBounds) {
        self.targetView.clipsToBounds = YES;
    } else {
        self.targetView.clipsToBounds = context.clipToBounds;
    }
}

@end
