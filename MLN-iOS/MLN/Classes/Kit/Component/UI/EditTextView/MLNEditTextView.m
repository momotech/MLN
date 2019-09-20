//
//  MLNEditTextView.m
//
//
//  Created by MoMo on 2018/7/30.
//

#import "MLNEditTextView.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "MLNBlock.h"
#import "MLNStringUtil.h"
#import "MLNLayoutEngine.h"
#import "MLNTextViewFactory.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNSizeCahceManager.h"
#import "MLNBeforeWaitingTask.h"

@interface MLNEditTextView () <MLNTextViewDelegate>{
    BOOL _singleLine;
}

@property (nonatomic, strong) UIView<MLNTextViewProtocol> *internalTextView;

@property (nonatomic, assign) MLNInternalTextViewType type;
@property (nonatomic, assign) MLNInternalTextViewType originType;

@property (nonatomic, strong) MLNBlock *beginChangingCallback;
@property (nonatomic, strong) MLNBlock *didChangingCallback;
@property (nonatomic, strong) MLNBlock *endChangedCallback;
@property (nonatomic, strong) MLNBlock *returnCallback;

@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;
@end
@implementation MLNEditTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = MLNInternalTextViewTypeMultableLine;
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.internalTextView];
}

#pragma mark - Responder
- (BOOL)isFirstResponder
{
    return [_internalTextView isFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [_internalTextView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [_internalTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [_internalTextView resignFirstResponder];
}

#pragma mark - Getter

- (MLNBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            sself.internalTextView.frame = UIEdgeInsetsInsetRect(sself.bounds, sself.padding);
        }];
    }
    return _lazyTask;
}

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _backgroundImageView;
}

- (UIView<MLNTextViewProtocol> *)internalTextView
{
    if (!_internalTextView) {
        _internalTextView = [MLNTextViewFactory createInternalTextViewByType:self.type withTempTextView:nil];
        _internalTextView.internalTextViewDelegate = self;
    }
    return _internalTextView;
}

#pragma mark - MLNInternalTextViewProtocl
- (void)internalTextViewDidBeginEditing:(UIView<MLNTextViewProtocol> *)internalTextView
{
    if (self.beginChangingCallback) {
        [self.beginChangingCallback callIfCan];
    }
}

- (BOOL)internalTextView:(UIView<MLNTextViewProtocol> *)internalTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"\n" isEqualToString:text]) {
        if (self.returnCallback) {
            [self.returnCallback callIfCan];
        }
        if (self.internalTextView.isSecureTextEntry) {
            return NO;
        }
    }
    if (self.internalTextView.keyboardType == UIKeyboardTypeNumberPad && text != nil) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (![text isEqualToString:filtered])
        {
            return NO;
        }
    }
    BOOL shouldChange = [self myTextView:internalTextView shouldReturnWithRange:range replacementString:text];
    if (self.didChangingCallback && shouldChange && range.location <= internalTextView.text.length) {
        NSString *newString = [internalTextView.text stringByReplacingCharactersInRange:range withString:text];
        if (internalTextView.text.length > 0 || text.length > 0) {
            [self.didChangingCallback addStringArgument:newString];
            [self.didChangingCallback addUIntegerArgument:range.location];
            [self.didChangingCallback addUIntegerArgument:text.length];
            [self.didChangingCallback callIfCan];
        }
    }
    return shouldChange;
}

- (void)internalTextViewDidChange:(UIView<MLNTextViewProtocol> *)internalTextView
{
    if (self.type == MLNInternalTextViewTypeMultableLine && self.lua_node.isWrapContent) {
        [self lua_needLayoutAndSpread];
    }
    
    // bind each other , the key must be attrs
    if (!_maxBytes && !_maxLength) {
        if (self.endChangedCallback) {
            [self.endChangedCallback addStringArgument:internalTextView.text];
            [self.endChangedCallback callIfCan];
        }
        return;
    }
    NSString *language =  [internalTextView.textInputMode primaryLanguage];
    if([language isEqualToString:@"zh-Hans"]){ //简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [internalTextView markedTextRange];
        UITextPosition *position = [internalTextView positionFromPosition:selectedRange.start offset:0];
        
        if (!position){//非高亮
            if (_maxBytes) {
                BOOL needSplice = [MLNStringUtil constraintString:[internalTextView text] specifiedLength:_maxBytes];
                if (needSplice) {
                    internalTextView.text = [MLNStringUtil constrainString:[internalTextView text] toMaxLength:_maxBytes];
                }
            } else {
                BOOL needSplice = [internalTextView text].length > _maxLength;
                if (needSplice) {
                    NSRange range = [internalTextView.text rangeOfComposedCharacterSequenceAtIndex:_maxLength];
                    internalTextView.text = [internalTextView.text substringToIndex:range.location];
                }
            }
        }
    } else {
        if (_maxBytes) {
            BOOL needSplice = [MLNStringUtil constraintString:[internalTextView text] specifiedLength:_maxBytes];
            if (needSplice) {
                internalTextView.text = [MLNStringUtil constrainString:[internalTextView text] toMaxLength:_maxBytes];
            }
        } else {
            BOOL needSplice = [internalTextView text].length > _maxLength;
            if (needSplice) {
                NSRange range = [internalTextView.text rangeOfComposedCharacterSequenceAtIndex:_maxLength];
                internalTextView.text = [internalTextView.text substringToIndex:range.location];
            }
        }
    }
    if (self.endChangedCallback) {
        [self.endChangedCallback addStringArgument:internalTextView.text];
        [self.endChangedCallback callIfCan];
    }
}

- (BOOL)myTextView:(UIView<MLNTextViewProtocol> *)textView shouldReturnWithRange:(NSRange)range replacementString:(NSString *)string
{
    if (_maxBytes || _maxLength) {
        NSString *newString = @"";
        if (range.location <= textView.text.length) {
            newString = [textView.text stringByReplacingCharactersInRange:range withString:string];
        }
        NSString *lang = [textView.textInputMode primaryLanguage];
        if([lang isEqualToString:@"zh-Hans"]){ //简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [textView markedTextRange];
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            if (!position){//非高亮
                if (_maxBytes) {
                    return ![MLNStringUtil constraintString:newString specifiedLength:_maxBytes+1];
                } else {
                    return newString.length <= _maxLength;
                }
            }
        } else {
            if (_maxBytes) {
                return ![MLNStringUtil constraintString:newString specifiedLength:_maxBytes+1];
            } else {
                return newString.length <= _maxLength;
            }
        }
    }
    return YES;
}

#pragma mark - Exporter
- (BOOL)canEdit
{
    return self.internalTextView.editable;
}

- (void)setCanEdit:(BOOL)canEdit
{
    self.internalTextView.editable = canEdit;
}

- (void)lua_setCanEdit:(BOOL)canEdit
{
    self.internalTextView.editable = canEdit;
}

- (void)setText:(NSString *)text
{
    if (self.type == MLNInternalTextViewTypeSingleLine) {
        text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    self.internalTextView.text = text;
    if (self.type == MLNInternalTextViewTypeMultableLine && self.lua_node.isWrapContent) {
        [self lua_needLayoutAndSpread];
    }
}

- (NSString *)text
{
    return self.internalTextView.text;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.internalTextView.textAlignment = textAlignment;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    if (![placeholder isKindOfClass:[NSString class]] && placeholder != nil) {
        MLNKitLuaAssert(NO , @"The placeholder type must be String" );
        return;
    }
    if (self.type == MLNInternalTextViewTypeSingleLine) {
        placeholder = [placeholder stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    self.internalTextView.placeholder = placeholder;
    if (self.type == MLNInternalTextViewTypeMultableLine && self.lua_node.isWrapContent) {
        [self lua_needLayoutAndSpread];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    self.internalTextView.placeholderColor = placeholderColor;
}

- (UIColor *)placeholderColor
{
    return self.internalTextView.placeholderColor;
}

- (NSString *)placeholder
{
    return self.internalTextView.placeholder;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.internalTextView.textColor = textColor;
}

- (UIColor *)textColor
{
    return self.internalTextView.textColor;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.internalTextView.attributedText = attributedText;
    if (self.type == MLNInternalTextViewTypeMultableLine && self.lua_node.isWrapContent) {
        [self lua_needLayoutAndSpread];
    }
}

- (NSAttributedString *)attributedText
{
    return self.internalTextView.attributedText;
}

- (void)lua_setFonrSize:(CGFloat)fontSize
{
    self.internalTextView.font = [UIFont systemFontOfSize:fontSize];
}

- (CGFloat)lua_fontSize
{
    return self.internalTextView.font.pointSize;
}

- (void)setInputMode:(MLNEditTextViewInputMode)inputMode
{
    switch (inputMode) {
        case MLNEditTextViewInputModeNumber:
            [self setType:MLNInternalTextViewTypeSingleLine];
            self.internalTextView.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            self.internalTextView.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

- (MLNEditTextViewInputMode)lua_inputMode
{
    switch (self.internalTextView.keyboardType) {
        case UIKeyboardTypeNumberPad:
            return MLNEditTextViewInputModeNumber;
            break;
        default:
            return MLNEditTextViewInputModeNormal;
            break;
    }
}

- (void)setPasswordMode:(BOOL)passwordMode
{
    if (_type == MLNInternalTextViewTypeMultableLine && passwordMode) {
        _originType = _type;
        [self lua_setSingleLine:YES];
    }
    self.internalTextView.secureTextEntry = passwordMode;
    if(_originType == MLNInternalTextViewTypeMultableLine && !passwordMode){
        _originType = MLNInternalTextViewTypeSingleLine;
        [self lua_setSingleLine:NO];
    }
}

- (BOOL)passwordMode
{
    return self.internalTextView.secureTextEntry;
}

- (void)setReturnMode:(MLNEditTextViewReturnType)returnMode
{
    if (_returnMode == returnMode) {
        return;
    }
    switch (returnMode) {
        case MLNEditTextViewReturnTypeGo:
            self.internalTextView.returnKeyType = UIReturnKeyGo;
            break;
        case MLNEditTextViewReturnTypeSearch:
            self.internalTextView.returnKeyType = UIReturnKeySearch;
            break;
        case MLNEditTextViewReturnTypeSend:
            self.internalTextView.returnKeyType = UIReturnKeySend;
            break;
        case MLNEditTextViewReturnTypeNext:
            self.internalTextView.returnKeyType = UIReturnKeyNext;
            break;
        case MLNEditTextViewReturnTypeDone:
            self.internalTextView.returnKeyType = UIReturnKeyDone;
            break;
        default:
            self.internalTextView.returnKeyType = UIReturnKeyDefault;
            break;
    }
    if ([self.internalTextView isFirstResponder]) {
        [self.internalTextView endEditing:YES];
        [self.internalTextView becomeFirstResponder];
    }
    _returnMode = returnMode;
}

- (void)lua_setPadding:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    self.padding = UIEdgeInsetsMake(top, left, bottom, right);
    if (self.type == MLNInternalTextViewTypeMultableLine && self.lua_node.isWrapContent) {
        [self lua_needLayoutAndSpread];
    }
    [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
}

- (void)lua_dismissKeyboard
{
    if ([self.internalTextView isFirstResponder]) {
        [self.internalTextView resignFirstResponder];
    }
}

- (void)lua_showKeyboard
{
    if ([self.internalTextView canBecomeFirstResponder]) {
        [self.internalTextView becomeFirstResponder];
    }
}

- (void)lua_fontName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont *font =  [UIFont fontWithName:fontName size:fontSize]?:[UIFont systemFontOfSize:fontSize];
    self.internalTextView.font = font;
    if (self.type == MLNInternalTextViewTypeMultableLine && self.lua_node.isWrapContent) {
        [self lua_needLayoutAndSpread];
    }
}

- (void)lua_setCursorColor:(UIColor *)color
{
    self.internalTextView.tintColor = color;
}

- (void)lua_setSingleLine:(BOOL)singleLine
{
    self.type = !singleLine;
}

- (void)setType:(MLNInternalTextViewType)type
{
    [self recreateInternalTextViewIfNeed:type];
    _type = type;
}

- (BOOL)lua_SingleLineType
{
    return !_type;
}

- (void)recreateInternalTextViewIfNeed:(MLNInternalTextViewType)type
{
    if (_internalTextView && _type != type) {
        UIView<MLNTextViewProtocol> *preInternalTextView = _internalTextView;
        _internalTextView = [MLNTextViewFactory createInternalTextViewByType:type withTempTextView:preInternalTextView];
        if ([preInternalTextView isFirstResponder]) {
            [_internalTextView becomeFirstResponder];
        }
        [preInternalTextView removeFromSuperview];
        [self lua_needLayoutAndSpread];
        [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
    }
}

#pragma mark - Layout For Lua
- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    NSString *cacheKey = [self remakeCacheKeyWithMaxWidth:maxWidth maxHeight:maxHeight];
    MLNSizeCahceManager *sizeCacheManager = MLN_KIT_INSTANCE(self.mln_luaCore).layoutEngine.sizeCacheManager;
    NSValue *sizeValue = [sizeCacheManager objectForKey:cacheKey];
    if (sizeValue) {
        return sizeValue.CGSizeValue;
    }
    maxWidth -= _padding.left + _padding.right;
    maxHeight -= _padding.top + _padding.bottom;
    CGSize size = [self.internalTextView sizeThatFits:CGSizeMake(maxWidth, maxHeight)];
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    size.width = size.width + _padding.left + _padding.right;
    size.height = size.height + _padding.top + _padding.bottom;
    [sizeCacheManager setObject:[NSValue valueWithCGSize:size] forKey:cacheKey];
    return size;
}

- (NSString *)remakeCacheKeyWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return [NSString stringWithFormat:@"%lu%@%@%ld%lu%f%f%f%f%f%f",(unsigned long)self.attributedText.hash,self.placeholder, self.text,(long)self.textAlignment,(unsigned long)self.font.hash,self.padding.top,self.padding.bottom,self.padding.left,self.padding.right, maxWidth, maxHeight];
}

- (void)lua_changedLayout
{
    [super lua_changedLayout];
    if (!CGRectEqualToRect(self.backgroundImageView.frame, self.bounds)) {
        self.backgroundImageView.frame = self.bounds;
    }
    CGRect textViewFrame = UIEdgeInsetsInsetRect(self.bounds, self.padding);
    if (!CGRectEqualToRect(textViewFrame, self.internalTextView.frame)) {
        self.internalTextView.frame = textViewFrame;
    }
}

- (void)lua_setMaxBytes:(NSInteger)bytes
{
    bytes = bytes >= 1 ? bytes : 1;
    BOOL shouldReload = _maxBytes > 0;
    self.maxBytes = bytes;
    shouldReload?[self internalTextViewDidChange:_internalTextView]:"";
}

- (void)lua_setMaxLength:(NSInteger)length
{
    length = length >= 1 ? length : 1;
    BOOL shouldReload = _maxLength > 0;
    self.maxLength = length;
    shouldReload?[self internalTextViewDidChange:_internalTextView]:"";
}

#pragma mark - Override
- (void)lua_addSubview:(UIView *)view
{
    MLNKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(placeholder, "setPlaceholder:","placeholder", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(placeholderColor, "setPlaceholderColor:","placeholderColor", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(textColor, "setTextColor:","textColor", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(fontSize, "lua_setFonrSize:","lua_fontSize", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(inputMode, "setInputMode:","lua_inputMode", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(passwordMode, "setPasswordMode:","passwordMode", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(returnMode, "setReturnMode:","returnMode", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(textAlign, "setTextAlignment:","textAlignment", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(maxBytes, "lua_setMaxBytes:","maxBytes", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(maxLength, "lua_setMaxLength:","maxLength", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(text, "setText:","text", MLNEditTextView)
LUA_EXPORT_VIEW_PROPERTY(singleLine, "lua_setSingleLine:","lua_SingleLineType", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(fontNameSize, "lua_fontName:size:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(setBeginChangingCallback, "setBeginChangingCallback:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(setDidChangingCallback, "setDidChangingCallback:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(setEndChangedCallback, "setEndChangedCallback:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(setReturnCallback, "setReturnCallback:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(setCanEdit, "lua_setCanEdit:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPadding:right:bottom:left:", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(dismissKeyboard, "lua_dismissKeyboard", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(showKeyboard, "lua_showKeyboard", MLNEditTextView)
LUA_EXPORT_VIEW_METHOD(setCursorColor, "lua_setCursorColor:", MLNEditTextView)
LUA_EXPORT_VIEW_END(MLNEditTextView, EditTextView, YES, "MLNView", NULL)

@end
