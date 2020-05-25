//
//  MLNUIColor.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIColor : NSObject <MLNUIEntityExportProtocol>

- (instancetype)initWithColor:(UIColor *)aColor;

@end

NS_ASSUME_NONNULL_END
