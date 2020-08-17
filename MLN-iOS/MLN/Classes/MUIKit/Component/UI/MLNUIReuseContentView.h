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
- (void)pushContentViewWithLuaCore:(MLNUILuaCore *)luaCore;
- (void)setupLayoutNodeIfNeed;
- (void)updateLuaContentViewIfNeed;
- (MLNUILuaTable *)getLuaTable;

- (BOOL)isInited;
- (void)initCompleted;

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight applySize:(BOOL)applySize;

- (UIView *)contentView;
- (NSString *)lastReueseId;
- (void)updateLastReueseId:(NSString *)lastReuaseId;

@end

typedef void(^MLNUIReuseContentViewDidChangeLayout)(void);

@interface MLNUIReuseContentView : MLNUIVStack

@property (nonatomic, strong, readonly) MLNUILuaTable *luaTable;
@property (nonatomic, assign, getter=isInited) BOOL inited;
@property (nonatomic, copy) NSString *lastReuaseId;
@property (nonatomic, strong) MLNUIReuseContentViewDidChangeLayout didChangeLayout;

- (instancetype)initWithFrame:(CGRect)frame cellView:(UIView<MLNUIReuseCellProtocol> *)cell;

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight applySize:(BOOL)applySize;

- (void)pushToLuaCore:(MLNUILuaCore *)luaCore;
- (void)setupLayoutNodeIfNeed;
- (void)updateFrameIfNeed;

@end

NS_ASSUME_NONNULL_END
