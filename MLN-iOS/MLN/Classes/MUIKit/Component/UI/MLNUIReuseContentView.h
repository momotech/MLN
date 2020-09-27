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
- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore;
- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize;

//- (void)updateLuaContentViewIfNeed;
- (MLNUILuaTable *)getLuaTable;

- (BOOL)isInited;
- (void)initCompleted;

/// 计算 cell 大小
/// @param maxSize 最大 size 限制
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateCellSizeWithMaxSize:(CGSize)maxSize apply:(BOOL)apply;

/// 计算 cell 大小
/// @param fitSize 若 fitSize 大于0，则计算结果将会以 fitSize 为准，且不大于 maxSize.
/// @param maxSize 最大 size 限制
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateCellSizeWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize apply:(BOOL)apply;

- (UIView *)contentView;
- (NSString *)lastReueseId;
- (void)updateLastReueseId:(NSString *)lastReuaseId;

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
/// @param fitSize 若 fitSize 大于0，则计算结果将会以 fitSize 为准，且不大于 maxSize.
/// @param maxSize 最大 size 限制
/// @param apply 是否将计算结果应用到 view 上，如果是，则会改变 view.frame.
- (CGSize)caculateContentViewSizeWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize  apply:(BOOL)apply;

//- (void)pushToLuaCore:(MLNUILuaCore *)luaCore;

- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore;
- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize;

//- (void)updateFrameIfNeed;

@end

@interface MLNUIReuseAutoSizeContentViewNode : MLNUILayoutNode

@end

@interface MLNUIReuseAutoSizeContentView : MLNUIReuseContentView

@end

NS_ASSUME_NONNULL_END
