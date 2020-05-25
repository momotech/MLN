//
//  MLNStyleStringConst.h
//
//
//  Created by MoMo on 2019/7/30.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"

typedef NS_ENUM(NSInteger, MLNStyleImageAlignType) {
    MLNStyleImageAlignTypeDefault = 0,
    MLNStyleImageAlignTypeTop = 1,
    MLNStyleImageAlignTypeCenter = 2,
    MLNStyleImageAlignTypeBottom
};


NS_ASSUME_NONNULL_BEGIN

@interface MLNStyleStringConst : NSObject <MLNGlobalVarExportProtocol>

@end

NS_ASSUME_NONNULL_END
