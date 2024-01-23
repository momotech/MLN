//
//  MLNStackConst.h
//  MLN
//
//  Created by MOMO on 2020/3/24.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MLNStackMainAlignment) {
    MLNStackMainAlignmentInvalid = 0,
    MLNStackMainAlignmentStart, ///< default value.
    MLNStackMainAlignmentCenter,
    MLNStackMainAlignmentEnd,
    MLNStackMainAlignmentSpaceBetween,
    MLNStackMainAlignmentSpaceAround,
    MLNStackMainAlignmentSpaceEvenly,
};

typedef NS_ENUM(NSInteger, MLNStackCrossAlignment) {
    MLNStackCrossAlignmentStart = 0,
    MLNStackCrossAlignmentCenter,
    MLNStackCrossAlignmentEnd,
};

@interface MLNStackConst : NSObject<MLNGlobalVarExportProtocol>

@end

NS_ASSUME_NONNULL_END
