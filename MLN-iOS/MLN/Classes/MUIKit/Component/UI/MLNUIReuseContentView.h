//
//  MLNReuseContentView.h
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNView.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNLuaTable;
@protocol MLNReuseCellProtocol <NSObject>

@required
- (void)pushContentViewWithLuaCore:(MLNLuaCore *)luaCore;
- (void)setupLayoutNodeIfNeed;
- (void)updateLuaContentViewIfNeed;
- (MLNLuaTable *)getLuaTable;

- (BOOL)isInited;
- (void)initCompleted;

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (void)requestLayoutIfNeed;
- (UIView *)contentView;
- (NSString *)lastReueseId;
- (void)updateLastReueseId:(NSString *)lastReuaseId;

@end

@interface MLNReuseContentView : MLNView

@property (nonatomic, strong, readonly) MLNLuaTable *luaTable;
@property (nonatomic, assign, getter=isInited) BOOL inited;
@property (nonatomic, copy) NSString *lastReuaseId;

- (instancetype)initWithFrame:(CGRect)frame cellView:(UIView<MLNReuseCellProtocol> *)cell;

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (void)pushToLuaCore:(MLNLuaCore *)luaCore;
- (void)setupLayoutNodeIfNeed;
- (void)updateFrameIfNeed;

@end

NS_ASSUME_NONNULL_END
