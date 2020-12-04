//
//  MLNUILabelT.m
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNUILabel.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitInstance.h"
#import "MLNUILayoutEngine.h"
#import "MLNUITextConst.h"
#import "MLNUIViewConst.h"
#import "MLNUIFont.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUISizeCahceManager.h"
#import "MLNUIBeforeWaitingTask.h"
#import "NSAttributedString+MLNUIKit.h"
#import "MLNUIStyleString.h"

@interface MLNUILabel ()

@property (nonatomic, strong) UILabel *innerLabel;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) MLNUIFontStyle fontStyle;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, copy) NSString *originText;
@property (nonatomic, assign) MLNUILabelMaxMode limitMode;
@property (nonatomic, assign) NSLineBreakMode labelBreakMode;
@end

@implementation MLNUILabel

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore frame:(CGRect)frame
{
    if (self = [super initWithMLNUILuaCore:luaCore frame:frame]) {
        self.labelBreakMode = NSLineBreakByTruncatingTail;
        self.userInteractionEnabled = YES;
        self.fontSize = kLuaDefaultFontSize;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self addSubview:self.innerLabel];
    }
}

- (void)calculatorAutoSize
{
    if (self.autoFit) {
        [self.innerLabel sizeToFit];
        CGRect frame = self.innerLabel.frame;
        frame.size.width = frame.size.width + self.mlnui_paddingLeft + self.mlnui_paddingRight;
        frame.size.height = frame.size.height + self.mlnui_paddingTop + self.mlnui_paddingBottom;
        self.frame = frame;
    }
}

- (void)setupBreakMode
{
    if (self.innerLabel.numberOfLines == 1) {
        self.innerLabel.lineBreakMode  = self.labelBreakMode;
    } else if(self.innerLabel.numberOfLines != 0 && (self.labelBreakMode == NSLineBreakByTruncatingTail || self.labelBreakMode == NSLineBreakByClipping)){
        self.innerLabel.lineBreakMode = self.labelBreakMode;
    } else {
        self.innerLabel.lineBreakMode = NSLineBreakByClipping;
    }
}

#pragma mark - Override

- (CGSize)mlnui_sizeThatFits:(CGSize)size {
    NSString *cacheKey = [self remakeCacheKeyWithMaxWidth:size.width maxHeight:size.height];
    MLNUISizeCahceManager *sizeCacheManager = MLNUI_KIT_INSTANCE(self.mlnui_luaCore).layoutEngine.sizeCacheManager;
    NSValue *sizeValue = [sizeCacheManager objectForKey:cacheKey];
    switch (_limitMode) {
        case MLNUILabelMaxModeValue:
            self.innerLabel.numberOfLines = 0;
            break;
        default:
            break;
    }
    if (sizeValue) {
        return sizeValue.CGSizeValue;
    }
    CGSize fitSize = [self.innerLabel sizeThatFits:CGSizeMake(size.width, size.height)];
    //满足条件则为加了行间距，且当前文本为单行，需要进行行间距消除
    if (_lineSpacing > 0 && floor(fitSize.height) <= ceil(self.font.lineHeight) + _lineSpacing) {
        CGFloat oldLineSpacing = _lineSpacing;
        _lineSpacing = 0;
        [self cleanLineSpacing];
        _lineSpacing = oldLineSpacing;
        fitSize.height -= _lineSpacing;
    }
    fitSize.width = ceil(fitSize.width);
    fitSize.height = ceil(fitSize.height);
    [sizeCacheManager setObject:[NSValue valueWithCGSize:fitSize] forKey:cacheKey];
    return fitSize;
}

//当只有一行时，清除行间距
- (void)cleanLineSpacing
{
    NSMutableAttributedString* strM = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:0];        //设置行间距
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    [strM addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.attributedText.length)];
    self.attributedText = strM;
}

- (NSString *)remakeCacheKeyWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return [NSString stringWithFormat:@"%lu%@%ld%lu%f%f%f%f%ld%f%f%lu",(unsigned long)self.attributedText.hash, self.text,(long)self.textAlignment,(unsigned long)self.font.hash,self.mlnui_paddingTop,self.mlnui_paddingBottom,self.mlnui_paddingLeft,self.mlnui_paddingRight,(long)self.numberOfLines, maxWidth, maxHeight, (unsigned long)_limitMode];
}

#pragma mark - Getter & Setter
- (void)setText:(NSString *)text
{
    if ([self.text isEqualToString:text]) {
        return;
    }
    [self mlnui_markNeedsLayout];
    self.innerLabel.text = [self mlnui_handleSingleLineBreakLineWithText:text];
}

- (NSString *)text
{
    return self.innerLabel.text?:@"";
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (![attributedText isKindOfClass:[NSAttributedString class]]) {
        MLNUIKitLuaError(@"Error! Cannot assign a non-StyleString type to label styleText ");
        return;
    }
    if (self.attributedText == attributedText) {
        return;
    }
    
    if (attributedText.luaui_styleString) {
        __weak typeof(self) weakSelf = self;
        attributedText.luaui_styleString.loadFinishedCallback = ^(NSAttributedString *attributeText) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setAttributedText:[attributedText copy]];
        };
        [attributedText.luaui_styleString mlnui_checkImageIfNeed];
    }
    
    NSMutableAttributedString* strM = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:_lineSpacing == 0?2:_lineSpacing];        //设置行间距
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    [strM addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
    attributedText = strM;
    
    self.innerLabel.attributedText = attributedText;
    [self mlnui_markNeedsLayout];
}

- (void)luaui_setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    [self handleLineSpacing];
}

- (NSAttributedString *)attributedText
{
    return self.innerLabel.attributedText;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    _limitMode = MLNUILabelMaxModeLines;
    if (self.numberOfLines == numberOfLines) {
        return;
    }
    [self mlnui_markNeedsLayout];
    self.innerLabel.numberOfLines = numberOfLines;
    [self mlnui_handleSingleLineBreakLineWithLine:numberOfLines];
    [self setupBreakMode];
}

- (NSInteger)numberOfLines
{
    return self.innerLabel.numberOfLines;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.innerLabel.textAlignment = textAlignment;
    [self handleLineSpacing];
}

- (NSTextAlignment)textAlignment
{
    return self.innerLabel.textAlignment;
}

- (void)setFont:(UIFont *)font
{
    self.innerLabel.font = font;
    [self handleLineSpacing];
}

- (UIFont *)font
{
    return self.innerLabel.font;
}

- (void)setTextColor:(UIColor *)textColor
{
    MLNUICheckTypeAndNilValue(textColor, @"Color", [UIColor class])
    self.innerLabel.textColor = textColor;
    [self handleLineSpacing];
}

- (UIColor *)textColor
{
    return self.innerLabel.textColor;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    self.labelBreakMode = lineBreakMode;
    [self setupBreakMode];
}

- (NSLineBreakMode)lineBreakMode
{
    return self.innerLabel.lineBreakMode;
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    self.innerLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
}

- (CGFloat)preferredMaxLayoutWidth
{
    return self.innerLabel.preferredMaxLayoutWidth;
}

- (UILabel *)innerLabel
{
    if (!_innerLabel) {
        _innerLabel = [[UILabel alloc] init];
        _innerLabel.font = kLuaDefaultFont;
    }
    return _innerLabel;
}

#pragma mark - Export Methods
- (void)luaui_setFontOfSize:(CGFloat)size
{
    if (self.fontSize == size) {
        return;
    }
    [self mlnui_markNeedsLayout];
    self.fontSize = size;
    UIFont *font = self.font;
    if (font) {
        font = [font fontWithSize:size];
    } else {
        font = [UIFont systemFontOfSize:size];
    }
    self.font = font;
    [self handleLineSpacing];
}

- (CGFloat)luaui_fontSize
{
    return self.innerLabel.font.pointSize;
}

- (void)luaui_setTextBold
{
    MLNUILuaAssert(self.mlnui_luaCore, NO, @"Label:setTextBold method is deprecated, use setTextFontStyle instead!");
    [self luaui_setTextFontStyle:MLNUIFontStyleBold];
}

- (void)luaui_setTextFontStyle:(MLNUIFontStyle)style
{
    if (self.fontStyle == style) {
        return;
    }
    self.fontStyle = style;
    [self mlnui_markNeedsLayout];
    self.font = [MLNUIFont fontWithFontName:nil fontStyle:style fontSize:self.fontSize instance:MLNUI_KIT_INSTANCE(self.mlnui_luaCore)];
    [self handleLineSpacing];
}

- (void)luaui_fontName:(NSString *)fontName size:(CGFloat)fontSize
{
    MLNUICheckStringTypeAndNilValue(fontName)
    if (self.fontSize == fontSize && [self.fontName isEqualToString:fontName]) {
        return;
    }
    [self mlnui_markNeedsLayout];
    self.fontSize = fontSize;
    self.fontName = fontName;
    //获取失败后使用系统默认字体样式
    UIFont *newFont = [UIFont fontWithName:fontName size:fontSize];
    self.font = newFont ?:[UIFont systemFontOfSize:fontSize];
    [self handleLineSpacing];
}

- (void)luaui_setText:(NSString *)text
{
    if (![text isKindOfClass:[NSString class]]) {
//        MLNUILuaAssert(self.mlnui_luaCore, [text isKindOfClass:[NSString class]], @"Error! Cannot assign a non-NSString type to label ");
//        return;
        text = [NSString stringWithFormat:@"%@", text ?: @""];
    }
    self.text = text;
    [self handleLineSpacing];
}

- (void)luaui_setMaxHeight:(CGFloat)maxHeight
{
    _limitMode = MLNUILabelMaxModeValue;
    self.mlnui_layoutNode.maxHeight = MLNUIPointValue(maxHeight);
}

- (void)luaui_setMinHeight:(CGFloat)minHeight
{
    _limitMode = MLNUILabelMaxModeValue;
    self.mlnui_layoutNode.minHeight = MLNUIPointValue(minHeight);
}

- (void)handleLineSpacing {
    if (_lineSpacing == 0) {
        return;
    }
    NSString *labelText = self.text;
    if (labelText.length == 0) {
        return;
    }
    NSRange range = NSMakeRange(0, labelText.length);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.textColor range:range];
    [self setAttributedText:attributedString];
}

- (NSString *)mlnui_handleSingleLineBreakLineWithText:(NSString *)text
{
    self.originText = text;
    if (self.numberOfLines != 1) {
        return text;
    }
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        return  [text  stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    }
    return text;
}

- (void)mlnui_handleSingleLineBreakLineWithLine:(NSInteger)line
{
    if (line == 1 && [_originText rangeOfString:@"\n"].location != NSNotFound) {
        [self setText:[_originText stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
    } else if ((self.originText && line != 1) ) {
        [self setText:self.originText];
    }
}

#pragma mark - Overrid For Lua
- (BOOL)luaui_canClick
{
    return YES;
}

- (BOOL)luaui_canLongPress
{
    return YES;
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUILuaAssert(self.mlnui_luaCore, NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)luaui_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUILuaAssert(self.mlnui_luaCore, NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)luaui_removeAllSubViews
{
    MLNUILuaAssert(self.mlnui_luaCore, NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

#pragma mark - MLNUIPaddingContainerViewProtocol

- (UIView *)mlnui_contentView
{
    return self.innerLabel;
}

#pragma mark - Export To Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUILabel)
LUAUI_EXPORT_VIEW_PROPERTY(text, "luaui_setText:", "text", MLNUILabel)
LUAUI_EXPORT_VIEW_PROPERTY(textAlign, "setTextAlignment:", "textAlignment", MLNUILabel) // MLNUITextAlign
LUAUI_EXPORT_VIEW_PROPERTY(fontSize, "luaui_setFontOfSize:", "luaui_fontSize", MLNUILabel)
LUAUI_EXPORT_VIEW_PROPERTY(textColor, "setTextColor:", "textColor", MLNUILabel)
LUAUI_EXPORT_VIEW_PROPERTY(lines, "setNumberOfLines:", "numberOfLines", MLNUILabel)
LUAUI_EXPORT_VIEW_PROPERTY(breakMode, "setLineBreakMode:", "lineBreakMode", MLNUILabel)
LUAUI_EXPORT_VIEW_PROPERTY(styleText, "setAttributedText:", "attributedText", MLNUILabel)
LUAUI_EXPORT_VIEW_METHOD(padding, "luaui_setPaddingWithTop:right:bottom:left:", MLNUILabel)
LUAUI_EXPORT_VIEW_METHOD(setTextBold, "luaui_setTextBold", MLNUILabel)
LUAUI_EXPORT_VIEW_METHOD(setTextFontStyle, "luaui_setTextFontStyle:", MLNUILabel)
LUAUI_EXPORT_VIEW_METHOD(fontNameSize, "luaui_fontName:size:", MLNUILabel)
LUAUI_EXPORT_VIEW_METHOD(setWrapContent, "setLuaui_wrapContent:",MLNUILabel)
LUAUI_EXPORT_VIEW_METHOD(setLineSpacing, "luaui_setLineSpacing:",MLNUILabel) //SDK>=1.0.3，自适应时的限制
LUAUI_EXPORT_VIEW_END(MLNUILabel, Label, YES, "MLNUIView", "initWithMLNUILuaCore:frame:")
@end
