//
//  MLNUITextViewFactory.h
//
//
//  Created by MoMo on 2018/12/21.
//

#import <Foundation/Foundation.h>
#import "MLNUITextViewProtocol.h"

typedef enum : NSUInteger {
    MLNUIInternalTextViewTypeSingleLine = 0,
    MLNUIInternalTextViewTypeMultableLine = 1,
} MLNUIInternalTextViewType;

NS_ASSUME_NONNULL_BEGIN

@interface MLNUITextViewFactory : NSObject

+ (UIView<MLNUITextViewProtocol> *)createInternalTextViewByType:(MLNUIInternalTextViewType)type withTempTextView:(UIView<MLNUITextViewProtocol> * _Nullable)temp;

@end

NS_ASSUME_NONNULL_END
