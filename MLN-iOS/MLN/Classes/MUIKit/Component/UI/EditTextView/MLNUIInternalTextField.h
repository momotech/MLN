//
//  MLNInternalTextField.h
//
//
//  Created by MoMo on 2018/12/21.
//

#import <UIKit/UIKit.h>
#import "MLNTextViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNInternalTextField : UITextField  <MLNTextViewProtocol, UITextFieldDelegate>

@property (nonatomic, weak) id<MLNTextViewDelegate> internalTextViewDelegate;

@property (nonatomic, strong)  UIColor *placeholderColor;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) NSInteger maxBytes;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) BOOL canEdit;

@end

NS_ASSUME_NONNULL_END
