//
//  MLNUIKit.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#ifndef MLNUIKit_h
#define MLNUIKit_h

#define OCPERF 1

#if OCPERF
#define OCPERF_USE_LUD 1
#define OCPERF_UPDATE_LUACORE 1
#define OCPERF_USE_CF 1
//#define OCPERF_USE_C 1
#define OCPERF_PRE_REQUIRE 1
//#define OCPERF_COALESCE_BLOCK 1
#else
#define OCPERF_USE_LUD 0
#define OCPERF_UPDATE_LUACORE 0
#define OCPERF_USE_CF 0
//#define OCPERF_USE_C 0
#define OCPERF_PRE_REQUIRE 0
//#define OCPERF_COALESCE_BLOCK 0
#endif


#define OCPERF_USE_C 1
#define OCPERF_COALESCE_BLOCK 1

#import <UIKit/UIKit.h>

// 内核
#import "MLNUICore.h"

// Kit
#import "MLNUIKitHeader.h"
#import "MLNUIVersion.h"
#import "MLNUIKitViewController.h"
#import "MLNUIViewController.h"
#import "MLNUIViewController+DataBinding.h"
#import "MLNUIDataBinding.h"
#import "MLNUIDataBindingCBridge.h"
#import "NSArray+MLNUIKVO.h"
#import "NSObject+MLNUIKVO.h"
#import "MLNUIKVOObserverProtocol.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIKitEnvironment.h"
#import "MLNUILink.h"
#import "MLNUIKitInstanceFactory.h"

// View导出工具
#import "MLNUIViewExporterMacro.h"
#import "MLNUIEntityExporterMacro.h"

// UI
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
#import "MLNUIWaterfallView.h"
#import "MLNUIWaterfallLayout.h"
#import "MLNUIWaterfallAdapter.h"
#import "MLNUIEditTextView.h"
#import "MLNUIViewPager.h"
#import "MLNUIViewPagerAdapter.h"
#import "MLNUITabSegmentView.h"
#import "MLNUIReuseContentView.h"
#import "MLNUIScrollCallbackView.h"

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

// Animations
#import "MLNUIAnimator.h"
#import "MLNUIAnimation.h"
#import "MLNUIFrameAnimation.h"
// Canvas
#import "MLNUICanvasView.h"
#import "MLNUICanvasPaint.h"
#import "MLNUICanvasConst.h"
#import "MLNUICanvasPath.h"
#import "MLNUIShapeContext.h"

// 工具
#import "MLNUIBeforeWaitingTaskProtocol.h"
#import "MLNUIMainRunLoopObserver.h"
#import "MLNUIBeforeWaitingTaskEngine.h"
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
#import "MLNUINetworkReachabilityManager.h"
#import "MLNUILayoutEngine.h"
#import "MLNUISizeCahceManager.h"
#import "MLNUIFont.h"
#import "MLNUINinePatchImageFactory.h"

// 分类
#import "NSDictionary+MLNUISafety.h"
#import "NSArray+MLNUISafety.h"
#import "UIView+MLNUIKit.h"
#import "UIScrollView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"

#import "MLNUIPerformanceHeader.h"

#if DEBUG || 1
#define PSTART_TAG(type, _tag) [[[MLNUIKitInstanceHandlersManager defaultManager] performanceMonitor] onStart:type tag:_tag]
#define PSTART(type) PSTART_TAG(type, nil)


#define PEND_TAG_INFO(type, _tag, _info) [[[MLNUIKitInstanceHandlersManager defaultManager] performanceMonitor] onEnd:type tag:_tag info:_info]
#define PEND(type) PEND_TAG_INFO(type, nil, @"")

#define PDISPLAY(delay) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
    [[[MLNUIKitInstanceHandlersManager defaultManager] performanceMonitor] display];\
})

#define PCallOC(cls,sel)  [[[MLNUIKitInstanceHandlersManager defaultManager] performanceMonitor] callOCBridge:cls selector:sel]
#define PCallDB(func)  [[[MLNUIKitInstanceHandlersManager defaultManager] performanceMonitor] callDBBridge:func]
#define PCallC(func)  [[[MLNUIKitInstanceHandlersManager defaultManager] performanceMonitor] callCBridge:func]


#else
#define PSTART(type)
#define PSTART_TAG(type,tag)
#define PEND(type)
#define PEND_TAG_INFO(type,tag,info)
#define PDISPLAY(delay)
#define PCallOC(cls,sel)
#define PCallDB(func)
#define PCallC(func)
#endif

#endif /* MLNUIKit_h */
