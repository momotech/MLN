//
//  MLNInternalTextField.m
//
//
//  Created by MoMo on 2018/12/21.
//

#import "MLNInternalTextField.h"
#import "MLNTextConst.h"

@interface MLNInternalTextField ()

@property (nonatomic, strong)UIColor * placeHolderColor;

@end

@implementation MLNInternalTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        [self addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        self.textColor = [UIColor blackColor];
        self.tintColor = [UIColor blackColor];
        self.font = kLuaDefaultFont;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!_placeHolderColor) {
        [self setPlaceholderColor:kLuaDefaultPlaceHolderColor];
    }
}

- (void)setFont:(UIFont *)font
{
    super.font = font;
    [self updateAttributePlaceholder];
}

- (void)setEditable:(BOOL)editable
{
    self.enabled = editable;
}

- (BOOL)isEditable
{
    return self.isEnabled;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeHolderColor = placeholderColor;
    [self updateAttributePlaceholder];
}

- (UIColor *)placeholderColor
{
    return _placeHolderColor;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(MLNInternalTextField *)textField
{
    if ([self.internalTextViewDelegate respondsToSelector:@selector(internalTextViewDidBeginEditing:)]) {
        [self.internalTextViewDelegate internalTextViewDidBeginEditing:textField];
    }
}

- (BOOL)textField:(MLNInternalTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.internalTextViewDelegate respondsToSelector:@selector(internalTextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.internalTextViewDelegate internalTextView:textField shouldChangeTextInRange:range replacementText:string];
    }
    return YES;
}

- (void)textFieldDidChanged:(MLNInternalTextField *)textField
{
    if ([self.internalTextViewDelegate respondsToSelector:@selector(internalTextViewDidChange:)]) {
        [self.internalTextViewDelegate internalTextViewDidChange:textField];
    }
}

- (void)updateAttributePlaceholder
{
    if (!self.placeholder) {
        return;
    }
    NSDictionary *attribute = @{NSFontAttributeName : self.font? self.font : kLuaDefaultFont,
                                NSForegroundColorAttributeName : self.placeholderColor? self.placeholderColor : kLuaDefaultPlaceHolderColor};
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:self.placeholder attributes:attribute];
    self.attributedPlaceholder = placeholder;
}
@end
