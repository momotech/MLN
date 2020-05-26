//
//  MLNUIInternalTextField.h
//
//
//  Created by MoMo on 2018/12/21.
//

#import <UIKit/UIKit.h>
#import "MLNUITextViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIInternalTextField : UITextField  <MLNUITextViewProtocol, UITextFieldDelegate>

@property (nonatomic, weak) id<MLNUITextViewDelegate> internalTextViewDelegate;

@property (nonatomic, strong)  UIColor *placeholderColor;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) NSInteger maxBytes;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) BOOL canEdit;

@end

NS_ASSUME_NONNULL_END
