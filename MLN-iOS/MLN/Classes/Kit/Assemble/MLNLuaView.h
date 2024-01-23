//
//  MLNLuaView.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/10.
//

#import <UIKit/UIKit.h>
#import "MLNViewConst.h"
@class MLNWindow, MLNKitInstance, MLNViewLoadModel;
@protocol MLNLuaViewInspectorBuilderProtocol;

typedef enum : NSUInteger {
    MLNLuaViewWindowLayoutStrategyWrapContent = 0, // By default. 根据子视图进行填充
    MLNLuaViewWindowLayoutStrategyAbsolute, // 绝对的size 不会改变
} MLNLuaViewWindowLayoutStrategy;

NS_ASSUME_NONNULL_BEGIN

@interface MLNLuaView : UIView

@property (nonatomic, strong) MLNKitInstance *instance;

/// 预热虚拟机
+ (void)warmup;

/// 初始化一个 Lua View, View 会根据子视图进行填充
/// @param urlStr url 链接
+ (instancetype)luaViewWithUrl:(NSString *)urlStr;

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider;

/// 初始化一个 Lua View
/// @param urlStr url 链接
/// @param size View默认尺寸
/// @param heightType 高度的填充模式
/// @param widthType 宽度的填充模式
/// 填充模式分为
///    MLNLayoutMeasurementTypeIdle = 0,    view 的 size 等于给定的 size
///    MLNLayoutMeasurementTypeMatchParent = -1, 根据父视图限制 size 需要传递父视图
///    MLNLayoutMeasurementTypeWrapContent = -2,  根据子视图进行宽度或者高度的填充
+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                   withSize:(CGSize) size
            withHeightType:(MLNLayoutMeasurementType) heightType
            withWidthType:(MLNLayoutMeasurementType) widthType;

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                   withSize:(CGSize) size
            withHeightType:(MLNLayoutMeasurementType) heightType
            withWidthType:(MLNLayoutMeasurementType) widthType
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider;

/// 初始化一个 Lua View
/// @param urlStr  url 链接
/// @param view 父视图
/// @param heightType 高度的填充模式
/// @param widthType 宽度的填充模式
/// 填充模式分为
///    MLNLayoutMeasurementTypeIdle = 0,    view 的 size 等于给定的 size
///    MLNLayoutMeasurementTypeMatchParent = -1, 根据父视图限制 size 需要传递父视图
///    MLNLayoutMeasurementTypeWrapContent = -2,  根据子视图进行宽度或者高度的填充
+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                   withSuperView:(UIView * __nullable) view
            withHeightType:(MLNLayoutMeasurementType) heightType
            withWidthType:(MLNLayoutMeasurementType) widthType;

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                   withSuperView:(UIView * __nullable) view
            withHeightType:(MLNLayoutMeasurementType) heightType
            withWidthType:(MLNLayoutMeasurementType) widthType
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider;

- (void)setLoadModel:(MLNViewLoadModel *)loadModel;

- (id)updateCustomView:(NSMutableDictionary *) map;
@end

NS_ASSUME_NONNULL_END
