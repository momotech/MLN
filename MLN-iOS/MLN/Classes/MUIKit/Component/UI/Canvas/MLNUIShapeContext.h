//
//  MLNUIShapeContext.h
//
//
//  Created by MoMo on 2019/7/24.
//

#import <Foundation/Foundation.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIShapeContext : NSObject<MLNUIEntityExportProtocol>

- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore TargetView:(UIView *)targetView;

- (void)cleanShapes;

@end

NS_ASSUME_NONNULL_END
