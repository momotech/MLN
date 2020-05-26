//
//  MLNUITextViewFactory.m
//
//
//  Created by MoMo on 2018/12/21.
//

#import "MLNUITextViewFactory.h"
#import "MLNUIInternalTextView.h"
#import "MLNUIInternalTextField.h"

@implementation MLNUITextViewFactory

+ (UIView<MLNUITextViewProtocol> *)createInternalTextViewByType:(MLNUIInternalTextViewType)type withTempTextView:(UIView<MLNUITextViewProtocol> * _Nullable)temp
{
    UIView<MLNUITextViewProtocol> *new = nil;
    switch (type) {
        case MLNUIInternalTextViewTypeMultableLine:
            new = [[MLNUIInternalTextView alloc] initWithFrame:CGRectZero];
            break;
        default:
            new = [[MLNUIInternalTextField alloc] initWithFrame:CGRectZero];
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
