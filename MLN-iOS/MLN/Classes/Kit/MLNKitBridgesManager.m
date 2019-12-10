//
//  MLNKitBridgesManager.m
//  MLN
//
//  Created by MoMo on 2019/8/29.
//

#import "MLNKitBridgesManager.h"
#import "MLNKitInstance.h"
#import "MLNLuaCore.h"
// Kit Classes's View
#import "MLNView.h"
#import "MLNWindow.h"
#import "MLNLinearLayout.h"
#import "MLNAlert.h"
#import "MLNAnimationZoneView.h"
#import "MLNLabel.h"
#import "MLNButton.h"
#import "MLNImageView.h"
#import "MLNLoading.h"
#import "MLNScrollView.h"
#import "MLNSwitch.h"
#import "MLNToast.h"
#import "MLNTableView.h"
#import "MLNTableViewAdapter.h"
#import "MLNTableViewAutoFitAdapter.h"
#import "MLNCollectionView.h"
#import "MLNCollectionViewAdapter.h"
#import "MLNCollectionViewAutoFitAdapter.h"
#import "MLNCollectionViewFlowLayout.h"
#import "MLNCollectionViewGridLayout.h"
#import "MLNWaterfallView.h"
#import "MLNWaterfallLayout.h"
#import "MLNWaterfallAdapter.h"
#import "MLNEditTextView.h"
#import "MLNDialogView.h"
#import "MLNContainerWindow.h"
#import "MLNViewPager.h"
#import "MLNViewPagerAdapter.h"
#import "MLNTabSegmentView.h"
#import "MLNCollectionViewGridLayoutFix.h"
#import "MLNWaterfallLayoutFix.h"
// Kit Classes's Model
#import "MLNRect.h"
#import "MLNSize.h"
#import "MLNPoint.h"
#import "MLNColor.h"
#import "NSMutableArray+MLNArray.h"
#import "NSMutableDictionary+MLNMap.h"
#import "MLNStyleString.h"
// Kit Classes's Global Var
#import "MLNScrollViewConst.h"
#import "MLNViewConst.h"
#import "MLNSystemConst.h"
#import "MLNStyleStringConst.h"
#import "MLNTextConst.h"
#import "MLNAnimationConst.h"
#import "MLNEditTextViewConst.h"
#import "MLNHTTPConst.h"
#import "MLNFileConst.h"
#import "MLNContentMode.h"
// Utils
#import "MLNSystem.h"
#import "MLNHttp.h"
#import "MLNTimer.h"
#import "MLNClipboard.h"
#import "MLNBit.h"
#import "MLNStringUtil.h"
#import "MLNNavigator.h"
#import "MLNPreferenceUtils.h"
#import "MLNFile.h"
#import "MLNTypeUtil.h"
#import "MLNApplication.h"
#import "MLNNetworkReachability.h"
#import "mmoslib.h"
// Animations
#import "MLNAnimator.h"
#import "MLNAnimation.h"
#import "MLNFrameAnimation.h"
#import "MLNAlphaAnimation.h"
#import "MLNAnimationSet.h"
#import "MLNRotateAnimation.h"
#import "MLNScaleAnimation.h"
#import "MLNTranslateAnimation.h"
// Canvas
#import "MLNCanvasView.h"
#import "MLNCanvasPaint.h"
#import "MLNCanvasConst.h"
#import "MLNCanvasPath.h"
#import "MLNShapeContext.h"

@implementation MLNKitBridgesManager

- (instancetype)initWithUIInstance:(MLNKitInstance *)instance
{
    if (self = [super init]) {
        _instance = instance;
    }
    return self;
}

- (void)registerKit
{
    // 注册视图
    [self.instance registerClasses:self.viewClasses error:NULL];
    // 注册数据模型
    [self.instance registerClasses:self.modelClasses error:NULL];
    // 注册全局变量
    [self.instance registerClasses:self.gvarClasses error:NULL];
    // 注册工具
    [self.instance registerClasses:self.utilClasses error:NULL];
    // 注册C工具库
    luaopen_mmos(self.instance.luaCore.state);
    // 注册动画相关
    [self.instance registerClasses:self.animationClasses error:NULL];
    // 注册绘图相关
    [self.instance registerClasses:self.canvasClasses error:NULL];
}

static NSArray<Class<MLNExportProtocol>> *viewClasses;
- (NSArray<Class<MLNExportProtocol>> *)viewClasses
{
    if (!viewClasses) {
        viewClasses = @[[MLNView class],
                        [MLNWindow class],
                        [MLNLinearLayout class],
                        [MLNAlert class],
                        [MLNLabel class],
                        [MLNButton class],
                        [MLNImageView class],
                        [MLNLoading class],
                        [MLNScrollView class],
                        [MLNSwitch class],
                        [MLNToast class],
                        [MLNTableView class],
                        [MLNTableViewAdapter class],
                        [MLNTableViewAutoFitAdapter class],
                        [MLNCollectionView class],
                        [MLNCollectionViewAdapter class],
                        [MLNCollectionViewFlowLayout class],
                        [MLNCollectionViewAutoFitAdapter class],
                        [MLNCollectionViewGridLayout class],
                        [MLNCollectionViewGridLayoutFix class],
                        [MLNWaterfallView class],
                        [MLNWaterfallLayout class],
                        [MLNWaterfallLayoutFix class],
                        [MLNWaterfallAdapter class],
                        [MLNEditTextView class],
                        [MLNDialogView class],
                        [MLNContainerWindow class],
                        [MLNViewPager class],
                        [MLNViewPagerAdapter class],
                        [MLNTabSegmentView class]];
    }
    return viewClasses;
}

static NSArray<Class<MLNExportProtocol>> *modelClasses;
- (NSArray<Class<MLNExportProtocol>> *)modelClasses
{
    if (!modelClasses) {
        modelClasses = @[[MLNRect class],
                         [MLNSize class],
                         [MLNPoint class],
                         [MLNColor class],
                         [NSMutableArray class],
                         [NSMutableDictionary class],
                         [MLNStyleString class]];
    }
    return modelClasses;
}

static NSArray<Class<MLNExportProtocol>> *gvarClasses;
- (NSArray<Class<MLNExportProtocol>> *)gvarClasses
{
    if (!gvarClasses) {
        gvarClasses = @[[MLNScrollViewConst class],
                        [MLNViewConst class],
                        [MLNSystemConst class],
                        [MLNStyleStringConst class],
                        [MLNTextConst class],
                        [MLNEditTextViewConst class],
                        [MLNHTTPConst class],
                        [MLNFileConst class],
                        [MLNContentMode class]];
    }
    return gvarClasses;
}

static NSArray<Class<MLNExportProtocol>> *utilClasses;
- (NSArray<Class<MLNExportProtocol>> *)utilClasses
{
    if (!utilClasses) {
        utilClasses = @[[MLNSystem class],
                        [MLNTimer class],
                        [MLNHttp class],
                        [MLNClipboard class],
                        [MLNBit class],
                        [MLNStringUtil class],
                        [MLNNavigator class],
                        [MLNPreferenceUtils class],
                        [MLNFile class],
                        [MLNTypeUtil class],
                        [MLNApplication class],
                        [MLNNetworkReachability class]];
    }
    return utilClasses;
}

static NSArray<Class<MLNExportProtocol>> *animationClasses;
- (NSArray<Class<MLNExportProtocol>> *)animationClasses
{
    if (!animationClasses) {
        animationClasses = @[[MLNAnimator class],
                             [MLNAnimationConst class],
                             [MLNAnimation class],
                             [MLNFrameAnimation class],
                             [MLNAnimationZoneView class],
                             [MLNAlphaAnimation class],
                             [MLNAnimationSet class],
                             [MLNRotateAnimation class],
                             [MLNScaleAnimation class],
                             [MLNTranslateAnimation class]];
    }
    return animationClasses;
}

static NSArray<Class<MLNExportProtocol>> *canvasClasses;
- (NSArray<Class<MLNExportProtocol>> *)canvasClasses
{
    if (!canvasClasses) {
        canvasClasses = @[[MLNCanvasConst class],
                          [MLNCanvasView class],
                          [MLNCanvasPaint class],
                          [MLNCanvasPath class],
                          [MLNShapeContext class]];
    }
    return canvasClasses;
}

@end
