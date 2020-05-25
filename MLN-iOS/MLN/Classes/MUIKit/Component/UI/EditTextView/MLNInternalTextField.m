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

- (void)deleteBackward
{
    BOOL shouldChange = YES;
    if ([self.internalTextViewDelegate respondsToSelector:@selector(internalTextView:shouldChangeTextInRange:replacementText:)]) {
        shouldChange = [self.internalTextViewDelegate internalTextView:self shouldChangeTextInRange:[self mln_in_selectedRange] replacementText:@""];
    }
    if (shouldChange) {
        [super deleteBackward];
    }
}

- (BOOL)textField:(MLNInternalTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        return YES;
    }
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

- (NSRange)mln_in_selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:selectedRange.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:selectedRange.location + selectedRange.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

- (NSRange)selectedRange
{
    return [self mln_in_selectedRange];
}


@end
