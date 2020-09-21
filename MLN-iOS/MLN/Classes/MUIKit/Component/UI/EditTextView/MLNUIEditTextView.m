//
//  MLNUIEditTextView.m
//
//
//  Created by MoMo on 2018/7/30.
//

#import "MLNUIEditTextView.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIBlock.h"
#import "MLNUIStringUtil.h"
#import "MLNUILayoutEngine.h"
#import "MLNUITextViewFactory.h"
#import "UIView+MLNUILayout.h"
#import "MLNUISizeCahceManager.h"
#import "MLNUIBeforeWaitingTask.h"
#import "UIView+MLNUIKit.h"

@interface MLNUIEditTextView () <MLNUITextViewDelegate>{
    BOOL _singleLine;
}

@property (nonatomic, strong) UIView<MLNUITextViewProtocol> *internalTextView;

@property (nonatomic, assign) MLNUIInternalTextViewType type;
@property (nonatomic, assign) MLNUIInternalTextViewType originType;

@property (nonatomic, strong) MLNUIBlock *beginChangingCallback;
@property (nonatomic, strong) MLNUIBlock *shouldChangeCallback;
@property (nonatomic, strong) MLNUIBlock *didChangingCallback;
@property (nonatomic, strong) MLNUIBlock *endChangedCallback;
@property (nonatomic, strong) MLNUIBlock *returnCallback;

@property (nonatomic, copy) NSString *originString;
@property (nonatomic, copy) NSString *changedString;
@property (nonatomic, assign) NSRange newRange;
@property (nonatomic, assign) NSRange originSelectedRange;
@property (nonatomic, assign) BOOL switchToSecure;
@property (nonatomic, copy) NSString *cacheText;

@end
@implementation MLNUIEditTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = MLNUIInternalTextViewTypeMultableLine;
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

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _backgroundImageView;
}

- (UIView<MLNUITextViewProtocol> *)internalTextView
{
    if (!_internalTextView) {
        _internalTextView = [MLNUITextViewFactory createInternalTextViewByType:self.type withTempTextView:nil];
        _internalTextView.internalTextViewDelegate = self;
    }
    return _internalTextView;
}

#pragma mark - MLNUIInternalTextViewProtocl
- (void)internalTextViewDidBeginEditing:(UIView<MLNUITextViewProtocol> *)internalTextView
{
    if (self.beginChangingCallback) {
        [self.beginChangingCallback callIfCan];
    }
}

- (BOOL)internalTextView:(UIView<MLNUITextViewProtocol> *)internalTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"\n" isEqualToString:text] && _type == MLNUIInternalTextViewTypeSingleLine) {
        [self callReturnCallbackIfNeed];
        return NO;
    }
    if (self.internalTextView.keyboardType == UIKeyboardTypeNumberPad && text != nil) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (![text isEqualToString:filtered])
        {
            return NO;
        }
    }
    _originSelectedRange = [internalTextView selectedRange];
    return YES;
}

- (void)internalTextViewDidChange:(UIView<MLNUITextViewProtocol> *)internalTextView
{
    if (self.type == MLNUIInternalTextViewTypeMultableLine && self.mlnui_layoutNode.isWrapContent) {
        [self mlnui_markNeedsLayout];
    }
    //触发回调
    if ([_changedString isEqualToString:@"\n"]) {
        [self callReturnCallbackIfNeed];
    }
    //   刚切换密码模式的情况，需要将原始文本重新赋值，保持两端一致
    if (self.switchToSecure && self.cacheText) {
        self.text = self.cacheText;
        self.cacheText = nil;
    }
    UITextRange *markedTextRange = [internalTextView markedTextRange];
    //    有裁剪必要，先对设置限制数进行裁剪
    if (_maxBytes || _maxLength) {
        NSString *language =  [internalTextView.textInputMode primaryLanguage];
        if([language isEqualToString:@"zh-Hans"]){ //简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextPosition *position = [internalTextView positionFromPosition:markedTextRange.start offset:0];
            if (!position){//非高亮
                [self clipBeyondTextIfNeed:internalTextView];
            }
        } else {
            [self clipBeyondTextIfNeed:internalTextView];
        }
    }
    BOOL shouldChange = YES;
    [self calculateNewStringWhenSingleLineAndZHMode];
    if (_shouldChangeCallback && self.internalTextView.text.length - _originString.length > 0 && !markedTextRange) {
        NSString *currentText = [self.internalTextView text];
        NSRange currentRange = [self.internalTextView selectedRange];
        self.internalTextView.text = _originString;
        shouldChange = [self shouldChangeTextWith:_originString new:_changedString start:_newRange.location count:_newRange.length];
        if (shouldChange) {
            self.internalTextView.text = currentText;
            self.internalTextView.selectedRange = currentRange;
        } else {
            self.internalTextView.selectedRange = NSMakeRange(_newRange.location, 0);
        }
    }
    //  当没有高亮文本且有修改内容时，回调编辑
    if (_didChangingCallback && _changedString && !markedTextRange) {
        [self.didChangingCallback addStringArgument:shouldChange?_changedString:@""];
        [self.didChangingCallback addUIntegerArgument:_newRange.location + 1];
        [self.didChangingCallback addUIntegerArgument:shouldChange?_changedString.length:0];
        [self.didChangingCallback callIfCan];
    }
    //    当没有高亮文本时，回调编辑结束
    if (!markedTextRange) {
        [self callbackDidEndEditing:internalTextView];
        //     清空修改文本，在有待选文本的情况下,didChange会再次回调一次，需要使用这个文本
        _changedString = nil;
    }
    //    记录无高亮文本，处理UITextField无汉字shouldChange回调的问题
    _originString = [self unmarkedText];
    //    系统键盘替换多选文本内容会有一次删除了选中内容的回调，所以不需要加上选中长度，此处经过即清空。第三方键盘只会在shouldChange中回调修改了的文本，此处只走一次
    _originSelectedRange = NSMakeRange(0, 0);
}

- (BOOL)myTextView:(UIView<MLNUITextViewProtocol> *)textView shouldReturnWithRange:(NSRange)range replacementString:(NSString *)string
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
                    return ![MLNUIStringUtil constraintString:newString specifiedLength:_maxBytes+1];
                } else {
                    return newString.length <= _maxLength;
                }
            }
        } else {
            if (_maxBytes) {
                return ![MLNUIStringUtil constraintString:newString specifiedLength:_maxBytes+1];
            } else {
                return newString.length <= _maxLength;
            }
        }
    }
    return YES;
}

#pragma mark - Private func

- (void)callReturnCallbackIfNeed
{
    if (_returnCallback) {
        [_returnCallback callIfCan];
    }
}

- (void)callbackDidEndEditing:(UIView<MLNUITextViewProtocol> *)internalTextView
{
    if (_endChangedCallback) {
        [_endChangedCallback addStringArgument:[internalTextView text]?:@""];
        [_endChangedCallback callIfCan];
    }
}

- (void)clipBeyondTextIfNeed:(UIView<MLNUITextViewProtocol> *)internalTextView
{
    if (_maxBytes) {
        BOOL needSplice = [MLNUIStringUtil constraintString:[internalTextView text] specifiedLength:_maxBytes];
        if (needSplice) {
            internalTextView.text = [MLNUIStringUtil constrainString:[internalTextView text] toMaxLength:_maxBytes];
        }
    } else if(_maxLength){
        BOOL needSplice = [internalTextView text].length > _maxLength;
        if (needSplice) {
            NSRange range = [internalTextView.text rangeOfComposedCharacterSequenceAtIndex:_maxLength];
            internalTextView.text = [internalTextView.text substringToIndex:range.location];
        }
    }
}

- (BOOL)shouldChangeTextWith:(NSString *)now new:(NSString *)new start:(NSUInteger)start count:(NSUInteger)count
{
    if (_shouldChangeCallback) {
        [_shouldChangeCallback addStringArgument:now?:@""];
        [_shouldChangeCallback addStringArgument:new?:@""];
        [_shouldChangeCallback addUIntegerArgument:start + 1];
        [_shouldChangeCallback addUIntegerArgument:count];
        id result = [_shouldChangeCallback callIfCan];
        if ([result isKindOfClass:[NSNumber class]] && ![result boolValue]) {
            return NO;
        }
    }
    return YES;
}

- (void)setupSwitchStatusWityType:(MLNUIInternalTextViewType)type
{
    if (type == MLNUIInternalTextViewTypeSingleLine) {
        self.switchToSecure = [self passwordMode];
        self.cacheText = self.text;
    } else {
        self.switchToSecure = NO;
        self.cacheText = nil;
    }
}

- (NSString *)unmarkedText
{
    NSString *originText = self.internalTextView.text;
    UITextRange *range = [self.internalTextView markedTextRange];
    if (range) {
        // 获取以from为基准的to的偏移
        UITextPosition *selectionStart = range.start;
        UITextPosition *selectionEnd = range.end;
        NSInteger location = [self.internalTextView offsetFromPosition:0 toPosition:selectionStart];
        NSInteger length = [self.internalTextView offsetFromPosition:selectionStart toPosition:selectionEnd];
        originText = [self.internalTextView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
    }
    return originText;
}

//当单行模式中文输入时，存在_changedString异常情况，此时根据_originString和新的文本来计算出来_changedString和_newRange
- (void)calculateNewStringWhenSingleLineAndZHMode
{
    if (self.internalTextView.markedTextRange != nil) {
        return;
    }
    NSRange currentRange = self.internalTextView.selectedRange;
    NSInteger newLength = self.internalTextView.text.length - _originString.length;
    if (newLength < 0) {
        _changedString = @"";
        currentRange.length = -newLength;
        _newRange = currentRange;
    } else {
        //        这里增加选中长度是为了修复当用户多选了文本并替换时，系统键盘会先回调一次删除后的文本再回调，第三方键盘会在shouldChange中回调选中文本位置
        newLength += _originSelectedRange.length;
        currentRange.location -= newLength;
        currentRange.length = newLength;
        _changedString = [self.internalTextView.text substringWithRange:currentRange];
        _newRange = NSMakeRange(currentRange.location, _changedString.length);
    }
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

- (void)luaui_setCanEdit:(BOOL)canEdit
{
    self.internalTextView.editable = canEdit;
}

- (void)setText:(NSString *)text
{
    if (![text isKindOfClass:NSString.class]) {
        text = [NSString stringWithFormat:@"%@", text ?: @""];
    }
    if (self.type == MLNUIInternalTextViewTypeSingleLine) {
        text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    if (![self shouldChangeTextWith:self.internalTextView.text?:@"" new:text start:0 count:text.length]) {
        return;
    }
    self.internalTextView.text = text;
    [self clipBeyondTextIfNeed:self.internalTextView];
    text = self.internalTextView.text;
    if (self.type == MLNUIInternalTextViewTypeMultableLine && self.mlnui_layoutNode.isWrapContent) {
        [self mlnui_markNeedsLayout];
    }
    if (_didChangingCallback) {
        [_didChangingCallback addStringArgument:text?:@""];
        [_didChangingCallback addIntArgument:1];
        [_didChangingCallback addUIntegerArgument:text.length];
        [_didChangingCallback callIfCan];
    }
    [self callbackDidEndEditing:self.internalTextView];
    _originString = text;
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
    if (![placeholder isKindOfClass:[NSString class]]) {
//        MLNUIKitLuaAssert(NO , @"The placeholder type must be String" );
//        return;
        placeholder = [NSString stringWithFormat:@"%@", placeholder ?: @""];
    }
    if (self.type == MLNUIInternalTextViewTypeSingleLine) {
        placeholder = [placeholder stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    self.internalTextView.placeholder = placeholder;
    if (self.type == MLNUIInternalTextViewTypeMultableLine && self.mlnui_layoutNode.isWrapContent) {
        [self mlnui_markNeedsLayout];
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
    if (self.type == MLNUIInternalTextViewTypeMultableLine && self.mlnui_layoutNode.isWrapContent) {
        [self mlnui_markNeedsLayout];
    }
}

- (NSAttributedString *)attributedText
{
    return self.internalTextView.attributedText;
}

- (void)luaui_setFonrSize:(CGFloat)fontSize
{
    self.internalTextView.font = [UIFont systemFontOfSize:fontSize];
}

- (CGFloat)luaui_fontSize
{
    return self.internalTextView.font.pointSize;
}

- (void)setInputMode:(MLNUIEditTextViewInputMode)inputMode
{
    switch (inputMode) {
        case MLNUIEditTextViewInputModeNumber://数字模式，强行设置为单行模式
            [self setType:MLNUIInternalTextViewTypeSingleLine];
            self.internalTextView.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            self.internalTextView.keyboardType = UIKeyboardTypeDefault;
            break;
    }
    if ([self.internalTextView isFirstResponder] && _type == MLNUIInternalTextViewTypeSingleLine) {
        [self.internalTextView resignFirstResponder];
        [self.internalTextView becomeFirstResponder];
    }
}

- (MLNUIEditTextViewInputMode)luaui_inputMode
{
    switch (self.internalTextView.keyboardType) {
        case UIKeyboardTypeNumberPad:
            return MLNUIEditTextViewInputModeNumber;
            break;
        default:
            return MLNUIEditTextViewInputModeNormal;
            break;
    }
}

- (void)setPasswordMode:(BOOL)passwordMode
{
    if (_type == MLNUIInternalTextViewTypeMultableLine && passwordMode) {
        MLNUIKitLuaAssert(NO, @"Multi-line mode does not support password mode and should be set to single-line mode");
    }
    self.internalTextView.secureTextEntry = passwordMode;
    [self setupSwitchStatusWityType:_type];
}

- (BOOL)passwordMode
{
    return self.internalTextView.secureTextEntry;
}

- (void)setReturnMode:(MLNUIEditTextViewReturnType)returnMode
{
    if (_returnMode == returnMode) {
        return;
    }
    switch (returnMode) {
        case MLNUIEditTextViewReturnTypeGo:
            self.internalTextView.returnKeyType = UIReturnKeyGo;
            break;
        case MLNUIEditTextViewReturnTypeSearch:
            self.internalTextView.returnKeyType = UIReturnKeySearch;
            break;
        case MLNUIEditTextViewReturnTypeSend:
            self.internalTextView.returnKeyType = UIReturnKeySend;
            break;
        case MLNUIEditTextViewReturnTypeNext:
            self.internalTextView.returnKeyType = UIReturnKeyNext;
            break;
        case MLNUIEditTextViewReturnTypeDone:
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

- (void)luaui_dismissKeyboard
{
    if ([self.internalTextView isFirstResponder]) {
        [self.internalTextView resignFirstResponder];
    }
}

- (void)luaui_showKeyboard
{
    if ([self.internalTextView canBecomeFirstResponder]) {
        [self.internalTextView becomeFirstResponder];
    }
}

- (void)luaui_fontName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont *font =  [UIFont fontWithName:fontName size:fontSize]?:[UIFont systemFontOfSize:fontSize];
    self.internalTextView.font = font;
    if (self.type == MLNUIInternalTextViewTypeMultableLine && self.mlnui_layoutNode.isWrapContent) {
        [self mlnui_markNeedsLayout];
    }
}

- (void)luaui_setCursorColor:(UIColor *)color
{
    self.internalTextView.tintColor = color;
}

- (void)luaui_setSingleLine:(BOOL)singleLine
{
    self.type = !singleLine;
}

- (void)setType:(MLNUIInternalTextViewType)type
{
    [self recreateInternalTextViewIfNeed:type];
    _type = type;
}

- (BOOL)luaui_SingleLineType
{
    return !_type;
}

- (void)recreateInternalTextViewIfNeed:(MLNUIInternalTextViewType)type
{
    if (_internalTextView && _type != type) {
        UIView<MLNUITextViewProtocol> *preInternalTextView = _internalTextView;
        _internalTextView = [MLNUITextViewFactory createInternalTextViewByType:type withTempTextView:preInternalTextView];
        if ([preInternalTextView isFirstResponder]) {
            [_internalTextView becomeFirstResponder];
        }
        [preInternalTextView removeFromSuperview];
        [self setupSwitchStatusWityType:type];
    }
}

#pragma mark - Layout For Lua

- (NSString *)remakeCacheKeyWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return [NSString stringWithFormat:@"%lu%@%@%ld%lu%f%f%f%f%f%f",(unsigned long)self.attributedText.hash,self.placeholder, self.text,(long)self.textAlignment,(unsigned long)self.font.hash,self.padding.top,self.padding.bottom,self.padding.left,self.padding.right, maxWidth, maxHeight];
}

- (void)mlnui_layoutDidChange
{
    [super mlnui_layoutDidChange];
    if (!CGRectEqualToRect(self.backgroundImageView.frame, self.bounds)) {
        self.backgroundImageView.frame = self.bounds;
    }
    CGRect textViewFrame = UIEdgeInsetsInsetRect(self.bounds, self.padding);
    if (!CGRectEqualToRect(textViewFrame, self.internalTextView.frame)) {
        self.internalTextView.frame = textViewFrame;
    }
}

- (void)luaui_setMaxBytes:(NSInteger)bytes
{
    bytes = bytes >= 1 ? bytes : 1;
    BOOL shouldReload = _maxBytes > 0;
    self.maxBytes = bytes;
    shouldReload?[self internalTextViewDidChange:_internalTextView]:"";
    _maxLength = 0;
}

- (void)luaui_setMaxLength:(NSInteger)length
{
    length = length >= 1 ? length : 1;
    BOOL shouldReload = _maxLength > 0;
    self.maxLength = length;
    shouldReload?[self internalTextViewDidChange:_internalTextView]:"";
    _maxBytes = 0;
}

#pragma mark - Override

- (void)luaui_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)luaui_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (BOOL)mlnui_layoutEnable {
    return YES;
}

- (CGSize)mlnui_sizeThatFits:(CGSize)size {
    NSString *cacheKey = [self remakeCacheKeyWithMaxWidth:size.width maxHeight:size.height];
    MLNUISizeCahceManager *sizeCacheManager = MLNUI_KIT_INSTANCE(self.mlnui_luaCore).layoutEngine.sizeCacheManager;
    NSValue *sizeValue = [sizeCacheManager objectForKey:cacheKey];
    if (sizeValue) {
        return sizeValue.CGSizeValue;
    }
    CGSize fitSize = [self.internalTextView sizeThatFits:CGSizeMake(size.width, size.height)];
    fitSize.width = ceil(fitSize.width);
    fitSize.height = ceil(fitSize.height);
    [sizeCacheManager setObject:[NSValue valueWithCGSize:fitSize] forKey:cacheKey];
    return fitSize;
}

- (void)luaui_setPaddingWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left {
    self.padding = UIEdgeInsetsMake(top, left, bottom, right);
    [super luaui_setPaddingWithTop:top right:right bottom:bottom left:left];
}

- (void)setLuaui_paddingTop:(CGFloat)luaui_paddingTop {
    [super setLuaui_paddingTop:luaui_paddingTop];
    UIEdgeInsets insets = self.padding;
    insets.top = luaui_paddingTop;
    self.padding = insets;
}

- (void)setLuaui_paddingLeft:(CGFloat)luaui_paddingLeft {
    [super setLuaui_paddingLeft:luaui_paddingLeft];
    UIEdgeInsets insets = self.padding;
    insets.left = luaui_paddingLeft;
    self.padding = insets;
}

- (void)setLuaui_paddingRight:(CGFloat)luaui_paddingRight {
    [super setLuaui_paddingRight:luaui_paddingRight];
    UIEdgeInsets insets = self.padding;
    insets.right = luaui_paddingRight;
    self.padding = insets;
}

- (void)setLuaui_paddingBottom:(CGFloat)luaui_paddingBottom {
    [super setLuaui_paddingBottom:luaui_paddingBottom];
    UIEdgeInsets insets = self.padding;
    insets.bottom = luaui_paddingBottom;
    self.padding = insets;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, self.padding);
    if (!CGRectEqualToRect(frame, self.internalTextView.frame)) {
        self.internalTextView.frame = frame;
    }
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(placeholder, "setPlaceholder:","placeholder", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(placeholderColor, "setPlaceholderColor:","placeholderColor", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(textColor, "setTextColor:","textColor", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(fontSize, "luaui_setFonrSize:","luaui_fontSize", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(inputMode, "setInputMode:","luaui_inputMode", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(passwordMode, "setPasswordMode:","passwordMode", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(returnMode, "setReturnMode:","returnMode", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(textAlign, "setTextAlignment:","textAlignment", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(maxBytes, "luaui_setMaxBytes:","maxBytes", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(maxLength, "luaui_setMaxLength:","maxLength", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(text, "setText:","text", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_PROPERTY(singleLine, "luaui_setSingleLine:","luaui_SingleLineType", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(fontNameSize, "luaui_fontName:size:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setBeginChangingCallback, "setBeginChangingCallback:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setShouldChangeCallback, "setShouldChangeCallback:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setDidChangingCallback, "setDidChangingCallback:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setEndChangedCallback, "setEndChangedCallback:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setReturnCallback, "setReturnCallback:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setCanEdit, "luaui_setCanEdit:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(dismissKeyboard, "luaui_dismissKeyboard", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(showKeyboard, "luaui_showKeyboard", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_METHOD(setCursorColor, "luaui_setCursorColor:", MLNUIEditTextView)
LUAUI_EXPORT_VIEW_END(MLNUIEditTextView, EditTextView, YES, "MLNUIView", NULL)

@end
