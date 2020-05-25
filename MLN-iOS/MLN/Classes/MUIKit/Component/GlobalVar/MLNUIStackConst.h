//
//  MLNUIStackConst.h
//  MLNUI
//
//  Created by MOMO on 2020/3/24.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MLNUIStackMainAlignment) {
    MLNUIStackMainAlignmentInvalid = 0,
    MLNUIStackMainAlignmentStart, ///< default value.
    MLNUIStackMainAlignmentCenter,
    MLNUIStackMainAlignmentEnd,
    MLNUIStackMainAlignmentSpaceBetween,
    MLNUIStackMainAlignmentSpaceAround,
    MLNUIStackMainAlignmentSpaceEvenly,
};

typedef NS_ENUM(NSInteger, MLNUIStackCrossAlignment) {
    MLNUIStackCrossAlignmentStart = 0,
    MLNUIStackCrossAlignmentCenter,
    MLNUIStackCrossAlignmentEnd,
};

typedef NS_ENUM(NSInteger, MLNUIStackWrapType) {
    MLNUIStackWrapTypeNone = 0,
    MLNUIStackWrapTypeWrap = 1,
};

@interface MLNUIStackConst : NSObject<MLNUIGlobalVarExportProtocol>

@end

NS_ASSUME_NONNULL_END
