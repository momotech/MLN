//
//  MLNTextViewFactory.m
//
//
//  Created by MoMo on 2018/12/21.
//

#import "MLNTextViewFactory.h"
#import "MLNInternalTextView.h"
#import "MLNInternalTextField.h"

@implementation MLNTextViewFactory

+ (UIView<MLNTextViewProtocol> *)createInternalTextViewByType:(MLNInternalTextViewType)type withTempTextView:(UIView<MLNTextViewProtocol> * _Nullable)temp
{
    UIView<MLNTextViewProtocol> *new = nil;
    switch (type) {
        case MLNInternalTextViewTypeMultableLine:
            new = [[MLNInternalTextView alloc] initWithFrame:CGRectZero];
            break;
        default:
            new = [[MLNInternalTextField alloc] initWithFrame:CGRectZero];
            break;
    }
    if (temp) {
        new.text = temp.text;
        if (!new.text) {
            new.attributedText = temp.attributedText;
        }
        new.textAlignment = temp.textAlignment;
        new.keyboardType = temp.keyboardType;
        new.textColor = temp.textColor;
        new.font = temp.font;
        new.secureTextEntry = temp.isSecureTextEntry;
        new.returnKeyType = temp.returnKeyType;
        new.placeholder = temp.placeholder;
        new.placeholderColor = temp.placeholderColor;
        new.editable = temp.editable;
        new.tintColor = temp.tintColor;
        new.internalTextViewDelegate = temp.internalTextViewDelegate;
        if (temp.superview && !new.superview) {
            [temp.superview addSubview:new];
        }
    }
    return new;
}

@end
