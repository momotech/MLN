//
//  MLNUIEditTextView.h
//
//
//  Created by MoMo on 2018/7/30.
//

#import <UIKit/UIKit.h>
#import "MLNUIEditTextViewConst.h"
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIEditTextView : UIView <MLNUIEntityExportProtocol, UIResponderStandardEditActions>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) UIEdgeInsets padding;

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSInteger maxBytes;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, readonly) UITextRange *markedTextRange;
@property (nonatomic, assign) MLNUIEditTextViewReturnType returnMode;

@property (nonatomic, assign) BOOL canEdit;

/// It's either UITextView or UITextField.
@property (nonatomic, strong, readonly) UIView *actualResponderView;

@end

NS_ASSUME_NONNULL_END
