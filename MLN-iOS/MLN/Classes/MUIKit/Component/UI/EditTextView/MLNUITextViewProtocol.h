//
//  MLNUIInternalTextViewProtocl.h
//  Pods
//
//  Created by MoMo on 2018/12/21.
//

#ifndef MLNUIInternalTextViewProtocl_h
#define MLNUIInternalTextViewProtocl_h
#import <UIKit/UIKit.h>


@protocol MLNUITextViewProtocol;

@protocol MLNUITextViewDelegate <NSObject>

@optional
- (void)internalTextViewDidBeginEditing:(UIView<MLNUITextViewProtocol> *)internalTextView;
- (BOOL)internalTextView:(UIView<MLNUITextViewProtocol> *)internalTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)internalTextViewDidChange:(UIView<MLNUITextViewProtocol> *)internalTextView;

@end

@protocol MLNUITextViewProtocol <NSObject>

@property (nonatomic, weak) id<MLNUITextViewDelegate> internalTextViewDelegate;

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, assign) NSInteger maxBytes;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, readonly) UITextRange *markedTextRange;
@property (nonatomic, readonly) UITextPosition *beginningOfDocument;
@property (nonatomic, readonly) UITextPosition *endOfDocument;
@property (nonatomic, assign) NSRange selectedRange;

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition;
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset;
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset;
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other;
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition;

@end

#endif /* MLNUIInternalTextViewProtocl_h */
