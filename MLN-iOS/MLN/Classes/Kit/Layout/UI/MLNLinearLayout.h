//
//  MLNLinearLayout.h
//
//
//  Created by MoMo on 2018/10/15.
//

#import "MLNView.h"
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNLinearLayout : MLNView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore LayoutDirectionNumber:(NSNumber *)directionNum;
- (instancetype)initWithLayoutDirection:(MLNLayoutDirection)direction;

@property (nonatomic, assign) MLNLayoutDirection direction;

@end

NS_ASSUME_NONNULL_END
