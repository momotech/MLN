//
//  MLNUIEditTextViewConst.h
//
//
//  Created by MoMo on 2018/8/17.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNUIEditTextViewInputModeNormal = 1,
    MLNUIEditTextViewInputModeNumber = 2,
} MLNUIEditTextViewInputMode;

typedef enum : NSUInteger {
    MLNUIEditTextViewReturnTypeDefault = 1,
    MLNUIEditTextViewReturnTypeGo = 2,
    MLNUIEditTextViewReturnTypeSearch = 3,
    MLNUIEditTextViewReturnTypeSend = 4,
    MLNUIEditTextViewReturnTypeNext = 5,
    MLNUIEditTextViewReturnTypeDone = 6,
} MLNUIEditTextViewReturnType;

@interface MLNUIEditTextViewConst : NSObject <MLNUIGlobalVarExportProtocol>

@end

