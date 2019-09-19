//
//  MLNShapeContext.h
//
//
//  Created by MoMo on 2019/7/24.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNShapeContext : NSObject<MLNEntityExportProtocol>

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore TargetView:(UIView *)targetView;

- (void)cleanShapes;

@end

NS_ASSUME_NONNULL_END
