//
//  NSMutableArray+MLNLua.h
//  
//
//  Created by MoMo on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 将可变的数组导出为Lua 中的Array，不可变的数组则作为Lua Table
 */
@interface NSMutableArray (MLNArray) <MLNEntityExportProtocol>

@end

NS_ASSUME_NONNULL_END
