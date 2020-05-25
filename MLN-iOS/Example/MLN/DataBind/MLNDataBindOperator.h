//
//  MLNDataBindOperator.h
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/22.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MLNCore.h>
#import "MLNDataBindHotReload.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNDataBindOperator : NSObject <MLNEntityExportProtocol>

+ (void)setHotReload:(MLNDataBindHotReload *)hotReload;

@end

NS_ASSUME_NONNULL_END
