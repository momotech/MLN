//
//  MLNUIReuseContentView.h
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNUIVStack.h"
#import "UIView+MLNUILayout.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUILuaTable;
@protocol MLNUIReuseCellProtocol <NSObject>

@required

/// 创建 lua table 作为 lua 中的 cell.
/// 例如：adapter:initCell(function(cell)
///      --[[ 这里的 cell 便是该方法创建的 lua table --]]
/// end)
/// @param luaCore luaCore
- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore;
- (MLNUILuaTable *)getLuaTable;

/// 创建视图对应的Node
/// @param fitSize 若 fitSize 大于0 (0将会被忽略)，则计算结果将会以 fitSize 为准，且不大于 maxSize.
/// @param maxSize size 上限 (0将会被忽略)
- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize;

- (BOOL)isInited;
- (void)initCompleted;

/// 计算 cell 大小
/// @param maxSize 最大 size 限制
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateCellSizeWithMaxSize:(CGSize)maxSize apply:(BOOL)apply;

/// 计算 cell 大小
/// @param fitSize 若 fitSize 大于0 (0将会被忽略)，则计算结果将会以 fitSize 为准，且不大于 maxSize.
/// @param maxSize size 上限 (0将会被忽略)
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateCellSizeWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize apply:(BOOL)apply;

- (NSString *)lastReueseId;
- (void)updateLastReueseId:(NSString *)lastReuaseId;

@optional
- (UIView *)contentView;

@end

typedef void(^MLNUIReuseContentViewDidChangeLayout)(CGSize size);

@interface MLNUIReuseContentView : MLNUIVStack

@property (nonatomic, strong, readonly) MLNUILuaTable *luaTable;
@property (nonatomic, assign, getter=isInited) BOOL inited;
@property (nonatomic, copy) NSString *lastReuaseId;
@property (nonatomic, strong) MLNUIReuseContentViewDidChangeLayout didChangeLayout;

- (instancetype)initWithFrame:(CGRect)frame cellView:(UIView<MLNUIReuseCellProtocol> *)cell;

/// 计算 contentView 大小
/// @param maxSize 最大 size 限制
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateContentViewSizeWithMaxSize:(CGSize)maxSize apply:(BOOL)apply;

/// 计算 contentView 大小
/// @param fitSize 若 fitSize 大于0 (0将会被忽略)，则计算结果将会以 fitSize 为准，且不大于 maxSize.
/// @param maxSize size 上限 (0将会被忽略)
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateContentViewSizeWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize apply:(BOOL)apply;

/// 创建 lua table 作为 lua 中的 cell.
/// 例如：adapter:initCell(function(cell)
///      --[[ 这里的 cell 便是该方法创建的 lua table --]]
/// end)
/// @param luaCore luaCore
- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore;

/// 创建视图对应的Node
/// @param fitSize 若 fitSize 大于0 (0将会被忽略)，则计算结果将会以 fitSize 为准，且不大于 maxSize.
/// @param maxSize size 上限 (0将会被忽略)
- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize;

@end

@interface MLNUIReuseAutoSizeContentView : MLNUIReuseContentView

@end

NS_ASSUME_NONNULL_END
