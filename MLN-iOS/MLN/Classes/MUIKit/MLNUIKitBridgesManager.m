//
//  MLNUIKitBridgesManager.m
//  MLNUI
//
//  Created by MoMo on 2019/8/29.
//

#import "MLNUIKitBridgesManager.h"
#import "MLNUILuaCore.h"
#import "MLNUIKitInstance.h"
// Kit Classes's View
#import "MLNUIView.h"
#import "MLNUIWindow.h"
#import "MLNUIAlert.h"
#import "MLNUIAnimationZoneView.h"
#import "MLNUILabel.h"
#import "MLNUIButton.h"
#import "MLNUIImageView.h"
#import "MLNUILoading.h"
#import "MLNUIScrollView.h"
#import "MLNUISwitch.h"
#import "MLNUIToast.h"
#import "MLNUITableView.h"
#import "MLNUITableViewAdapter.h"
#import "MLNUITableViewAutoFitAdapter.h"
#import "MLNUICollectionView.h"
#import "MLNUICollectionViewAdapter.h"
#import "MLNUICollectionViewAutoFitAdapter.h"
#import "MLNUICollectionViewGridLayout.h"
#import "MLNUICollectionLayout.h"
#import "MLNUIWaterfallView.h"
#import "MLNUIWaterfallLayout.h"
#import "MLNUIWaterfallAdapter.h"
#import "MLNUIEditTextView.h"
#import "MLNUIViewPager.h"
#import "MLNUIViewPagerAdapter.h"
#import "MLNUITabSegmentView.h"
// Kit Classes's Model
#import "MLNUIRect.h"
#import "MLNUISize.h"
#import "MLNUIPoint.h"
#import "MLNUIColor.h"
#import "NSMutableArray+MLNUIArray.h"
#import "NSMutableDictionary+MLNUIMap.h"
#import "MLNUIStyleString.h"
// Kit Classes's Global Var
#import "MLNUIScrollViewConst.h"
#import "MLNUIViewConst.h"
#import "MLNUISystemConst.h"
#import "MLNUIStyleStringConst.h"
#import "MLNUITextConst.h"
#import "MLNUIAnimationConst.h"
#import "MLNUIEditTextViewConst.h"
#import "MLNUIHTTPConst.h"
#import "MLNUIFileConst.h"
#import "MLNUIContentMode.h"
#import "MLNUIStackConst.h"
// Utils
#import "MLNUISystem.h"
#import "MLNUIHttp.h"
#import "MLNUITimer.h"
#import "MLNUIClipboard.h"
#import "MLNUIBit.h"
#import "MLNUIStringUtil.h"
#import "MLNUINavigator.h"
#import "MLNUIPreferenceUtils.h"
#import "MLNUIFile.h"
#import "MLNUITypeUtil.h"
#import "MLNUIApplication.h"
#import "MLNUINetworkReachability.h"
#import "mmoslib.h"
#import "MLNUICornerUtil.h"
#import "MLNUISafeAreaAdapter.h"
#import "MLNUILink.h"
#import "MLNUIKit.h"
// Animations
#import "MLNUIAnimator.h"
#import "MLNUIAnimation.h"
#import "MLNUIFrameAnimation.h"

//New Animation
#import "MLNUIObjectAnimation.h"
#import "MLNUIObjectAnimationSet.h"
#import "MLNUIInteractiveBehavior.h"

// Canvas
#import "MLNUICanvasView.h"
#import "MLNUICanvasPaint.h"
#import "MLNUICanvasConst.h"
#import "MLNUICanvasPath.h"
#import "MLNUIShapeContext.h"
// Stack
#import "MLNUIStack.h"
#import "MLNUIVStack.h"
#import "MLNUIHStack.h"
#import "MLNUISpacer.h"

#import "ArgoDataBindingCBridge.h"

@interface MLNUIKitBridgesManager()
/**
 承载Kit库bridge和LuaCore实例
 */
@property (nonatomic, weak, readonly) MLNUIKitInstance *instance;
@end

@implementation MLNUIKitBridgesManager

- (void)registerKitForLuaCore:(MLNUILuaCore *)luaCore
{
    // 注册视图
    [luaCore registerClasses:self.viewClasses error:NULL];
    // 注册数据模型
    [luaCore registerClasses:self.modelClasses error:NULL];
    // 注册全局变量
    [luaCore registerClasses:self.gvarClasses error:NULL];
    // 注册工具
    [luaCore registerClasses:self.utilClasses error:NULL];
    // 注册C工具库
    luaopen_mmos(luaCore.state);
    // 注册动画相关
    [luaCore registerClasses:self.animationClasses error:NULL];
    // 注册绘图相关
    [luaCore registerClasses:self.canvasClasses error:NULL];
    // 注册新布局相关
    [luaCore registerClasses:self.stackClasses error:NULL];
#if OCPERF_PRE_REQUIRE
    //require lua file
    [self _requireCustomLuaFiles:luaCore];
#endif
}

//static const char *customLuaFiles[] = {"packet.BindMeta", "packet.KeyboardManager", "packet.style"};
//static const char *customLuaFiles[] = {"packet/BindMeta", "packet/KeyboardManager", "packet/style"};

- (void)_requireCustomLuaFiles:(MLNUILuaCore *)luaCore {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"ArgoUISystem" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirs = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    dirs = [dirs arrayByAddingObject:@""]; //添加根目录
    
    for (NSString *dirName in dirs) {
        NSArray *urls = [bundle URLsForResourcesWithExtension:@"lua" subdirectory:dirName];
        for (NSURL *url in urls) {
            NSString *requrieName = dirName.length > 0 ? [NSString stringWithFormat:@"%@/%@",dirName,[[url lastPathComponent] stringByDeletingPathExtension]] : [[url lastPathComponent] stringByDeletingPathExtension];
            [luaCore requireLuaFile:requrieName.UTF8String];
        }
    }
}

static NSArray<Class<MLNUIExportProtocol>> *viewClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)viewClasses
{
    if (!viewClasses) {
        viewClasses = @[[MLNUIView class],
                        [MLNUIWindow class],
                        [MLNUIAlert class],
                        [MLNUILabel class],
                        [MLNUIButton class],
                        [MLNUIImageView class],
                        [MLNUILoading class],
                        [MLNUIScrollView class],
                        [MLNUISwitch class],
                        [MLNUIToast class],
                        [MLNUITableView class],
                        [MLNUITableViewAdapter class],
                        [MLNUITableViewAutoFitAdapter class],
                        [MLNUICollectionView class],
                        [MLNUICollectionViewAdapter class],
                        [MLNUICollectionViewAutoFitAdapter class],
                        [MLNUICollectionViewGridLayout class],
                        [MLNUICollectionLayout class],
                        [MLNUIWaterfallView class],
                        [MLNUIWaterfallLayout class],
                        [MLNUIWaterfallAdapter class],
                        [MLNUIEditTextView class],
                        [MLNUIViewPager class],
                        [MLNUIViewPagerAdapter class],
                        [MLNUITabSegmentView class]];
    }
    return viewClasses;
}

static NSArray<Class<MLNUIExportProtocol>> *modelClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)modelClasses
{
    if (!modelClasses) {
        modelClasses = @[[MLNUIRect class],
                         [MLNUISize class],
                         [MLNUIPoint class],
                         [MLNUIColor class],
                         [NSMutableArray class],
                         [NSMutableDictionary class],
                         [MLNUIStyleString class]];
    }
    return modelClasses;
}

static NSArray<Class<MLNUIExportProtocol>> *gvarClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)gvarClasses
{
    if (!gvarClasses) {
        gvarClasses = @[[MLNUIScrollViewConst class],
                        [MLNUIViewConst class],
                        [MLNUISystemConst class],
                        [MLNUIStyleStringConst class],
                        [MLNUITextConst class],
                        [MLNUIEditTextViewConst class],
                        [MLNUIHTTPConst class],
                        [MLNUIFileConst class],
                        [MLNUIContentMode class],
                        [MLNUIStackConst class]];
    }
    return gvarClasses;
}

static NSArray<Class<MLNUIExportProtocol>> *utilClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)utilClasses
{
    if (!utilClasses) {
        utilClasses = @[[MLNUISystem class],
                        [MLNUITimer class],
                        [MLNUIHttp class],
                        [MLNUIClipboard class],
                        [MLNUIBit class],
                        [MLNUIStringUtil class],
                        [MLNUINavigator class],
                        [MLNUIPreferenceUtils class],
                        [MLNUIFile class],
                        [MLNUITypeUtil class],
                        [MLNUIApplication class],
                        [MLNUINetworkReachability class],
                        [MLNUICornerUtil class],
                        [MLNUISafeAreaAdapter class],
                        [MLNUILink class],
#if OCPERF_USE_C
    #if OCPERF_USE_NEW_DB
                        [ArgoDataBindingCBridge class],
    #else
                        [MLNUIDataBindingCBridge class],
    #endif
#else
                        [MLNUIDataBinding class],
#endif
        ];
    }
    return utilClasses;
}

static NSArray<Class<MLNUIExportProtocol>> *animationClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)animationClasses
{
    if (!animationClasses) {
        animationClasses = @[[MLNUIAnimator class],
                             [MLNUIAnimationConst class],
                             [MLNUIAnimation class],
                             [MLNUIFrameAnimation class],
                             [MLNUIAnimationZoneView class],
                             [MLNUIObjectAnimation class],
                             [MLNUIObjectAnimationSet class],
                             [MLNUIInteractiveBehavior class]
                            ];
    }
    return animationClasses;
}

static NSArray<Class<MLNUIExportProtocol>> *canvasClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)canvasClasses
{
    if (!canvasClasses) {
        canvasClasses = @[[MLNUICanvasConst class],
                          [MLNUICanvasView class],
                          [MLNUICanvasPaint class],
                          [MLNUICanvasPath class],
                          [MLNUIShapeContext class]];
    }
    return canvasClasses;
}

static NSArray<Class<MLNUIExportProtocol>> *stackClasses;
- (NSArray<Class<MLNUIExportProtocol>> *)stackClasses
{
    if (!stackClasses) {
        stackClasses = @[[MLNUIStack class],
                         [MLNUIPlaneStack class],
                         [MLNUIVStack class],
                         [MLNUIHStack class],
                         [MLNUISpacer class]];
    }
    return stackClasses;
}

@end

@implementation MLNUIKitBridgesManager (Deprecated)

- (instancetype)initWithUIInstance:(MLNUIKitInstance *)instance
{
    if (self = [super init]) {
        _instance = instance;
    }
    return self;
}

- (void)registerKit
{
    [self registerKitForLuaCore:self.instance.luaCore];
}

@end
