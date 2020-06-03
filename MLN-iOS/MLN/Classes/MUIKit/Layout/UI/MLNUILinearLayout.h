//
//  MLNUILinearLayout.h
//
//
//  Created by MoMo on 2018/10/15.
//

#import "MLNUIView.h"
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUILinearLayout : MLNUIView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore LayoutDirectionNumber:(NSNumber *)directionNum;
- (instancetype)initWithLayoutDirection:(MLNUILayoutDirection)direction;

@property (nonatomic, assign) MLNUILayoutDirection direction;

@end

NS_ASSUME_NONNULL_END
