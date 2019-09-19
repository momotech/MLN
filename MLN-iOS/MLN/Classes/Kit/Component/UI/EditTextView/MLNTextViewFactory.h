//
//  MLNTextViewFactory.h
//
//
//  Created by MoMo on 2018/12/21.
//

#import <Foundation/Foundation.h>
#import "MLNTextViewProtocol.h"

typedef enum : NSUInteger {
    MLNInternalTextViewTypeSingleLine = 0,
    MLNInternalTextViewTypeMultableLine = 1,
} MLNInternalTextViewType;

NS_ASSUME_NONNULL_BEGIN

@interface MLNTextViewFactory : NSObject

+ (UIView<MLNTextViewProtocol> *)createInternalTextViewByType:(MLNInternalTextViewType)type withTempTextView:(UIView<MLNTextViewProtocol> * _Nullable)temp;

@end

NS_ASSUME_NONNULL_END
