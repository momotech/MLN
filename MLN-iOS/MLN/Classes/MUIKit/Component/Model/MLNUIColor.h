//
//  MLNColor.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNColor : NSObject <MLNEntityExportProtocol>

- (instancetype)initWithColor:(UIColor *)aColor;

@end

NS_ASSUME_NONNULL_END
