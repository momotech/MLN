//
//  MLNLabelT.m
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNLabel.h"
#import "MLNViewExporterMacro.h"
#import "MLNKitHeader.h"
#import "MLNKitInstance.h"
#import "MLNLayoutEngine.h"
#import "MLNTextConst.h"
#import "MLNFont.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNSizeCahceManager.h"
#import "MLNBeforeWaitingTask.h"
#import "NSAttributedString+MLNKit.h"
#import "MLNStyleString.h"
#import "MLNLabel+Interface.h"
#import "MLNStyleElement.h"
#import <CoreText/CTFramesetter.h>
#import <CoreText/CTRun.h>

@interface MLNRunItem : NSObject
@property(nonatomic) CGRect            frame;
@property (nonatomic) NSRange           range;
@end

@implementation MLNRunItem
@end

@interface MLNLabel ()

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) MLNFontStyle fontStyle;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, copy) NSString *originText;
@property (nonatomic, assign) NSLineBreakMode labelBreakMode;
@property (nonatomic, copy) MLNStyleString *originString;
@property (nonatomic, strong) UITapGestureRecognizer *textTap;
@end

@implementation MLNLabel

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore frame:(CGRect)frame
{
    if (self = [super initWithLuaCore:luaCore frame:frame]) {
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
        frame.size.width = frame.size.width + self.lua_paddingLeft + self.lua_paddingRight;
        frame.size.height = frame.size.height + self.lua_paddingTop + self.lua_paddingBottom;
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

#pragma mark - Layout For Lua
- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    NSString *cacheKey = [self remakeCacheKeyWithMaxWidth:maxWidth maxHeight:maxHeight];
    MLNSizeCahceManager *sizeCacheManager = MLN_KIT_INSTANCE(self.mln_luaCore).layoutEngine.sizeCacheManager;
    NSValue *sizeValue = [sizeCacheManager objectForKey:cacheKey];
    switch (_limitMode) {
        case MLNLabelMaxModeValue:
            self.innerLabel.numberOfLines = 0;
            break;
        default:
            break;
    }
    if (sizeValue) {
        return sizeValue.CGSizeValue;
    }
    maxWidth -= self.lua_paddingLeft + self.lua_paddingRight;
    maxHeight -= self.lua_paddingTop + self.lua_paddingBottom;
    CGSize size = [self.innerLabel sizeThatFits:CGSizeMake(maxWidth, maxHeight)];
    //满足条件则为加了行间距，且当前文本为单行，需要进行行间距消除
    if (_lineSpacing > 0 && floor(size.height)  <= ceil(self.font.lineHeight) + _lineSpacing) {
        CGFloat oldLineSpacing = _lineSpacing;
        _lineSpacing = 0;
        [self cleanLineSpacing];
        _lineSpacing = oldLineSpacing;
        size.height -= _lineSpacing;
    }
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    size.width = size.width + self.lua_paddingLeft + self.lua_paddingRight;
    size.height = size.height + self.lua_paddingTop + self.lua_paddingBottom;
    [sizeCacheManager setObject:[NSValue valueWithCGSize:size] forKey:cacheKey];
    return size;
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
    return [NSString stringWithFormat:@"%lu%@%ld%lu%f%f%f%f%ld%f%f%lu",(unsigned long)self.attributedText.hash, self.text,(long)self.textAlignment,(unsigned long)self.font.hash,self.lua_paddingTop,self.lua_paddingBottom,self.lua_paddingLeft,self.lua_paddingRight,(long)self.numberOfLines, maxWidth, maxHeight, (unsigned long)_limitMode];
}

#pragma mark - Getter & Setter
- (void)setText:(NSString *)text
{
    if ([self.text isEqualToString:text]) {
        return;
    }
    self.originString = nil;
    [self lua_needLayoutAndSpread];
    self.innerLabel.text = [self mln_handleSingleLineBreakLineWithText:text];
}

- (NSString *)text
{
    return self.innerLabel.text?:@"";
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (![attributedText isKindOfClass:[NSAttributedString class]]) {
        MLNKitLuaError(@"Error! Cannot assign a non-StyleString type to label styleText ");
        return;
    }
    if (self.attributedText == attributedText) {
        return;
    }
    
    if (attributedText.lua_styleString) {
        self.originString = attributedText.lua_styleString;
        __weak typeof(self) weakSelf = self;
        attributedText.lua_styleString.loadFinishedCallback = ^(NSAttributedString *attributeText) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setAttributedText:[attributedText copy]];
        };
        [attributedText.lua_styleString mln_checkImageIfNeed];
    } else {
        self.originString = nil;
    }
    
    NSMutableAttributedString* strM = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:_lineSpacing == 0?2:_lineSpacing];        //设置行间距
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    [strM addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
    attributedText = strM;
    
    self.innerLabel.attributedText = attributedText;
    [self lua_needLayoutAndSpread];
}

- (void)lua_setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    [self handleLineSpacing];
}

- (NSAttributedString *)attributedText
{
    return self.innerLabel.attributedText;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    [self setLua_maxHieght:0];
    _limitMode = MLNLabelMaxModeLines;
    if (self.numberOfLines == numberOfLines) {
        return;
    }
    [self lua_needLayoutAndSpread];
    self.innerLabel.numberOfLines = numberOfLines;
    [self mln_handleSingleLineBreakLineWithLine:numberOfLines];
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
    MLNCheckTypeAndNilValue(textColor, @"Color", [UIColor class])
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
- (void)lua_setFontOfSize:(CGFloat)size
{
    if (self.fontSize == size) {
        return;
    }
    [self lua_needLayoutAndSpread];
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

- (CGFloat)lua_fontSize
{
    return self.innerLabel.font.pointSize;
}

- (void)lua_setTextBold
{
    MLNLuaAssert(self.mln_luaCore, NO, @"Label:setTextBold method is deprecated, use setTextFontStyle instead!");
    [self lua_setTextFontStyle:MLNFontStyleBold];
}

- (void)lua_setTextFontStyle:(MLNFontStyle)style
{
    if (self.fontStyle == style) {
        return;
    }
    self.fontStyle = style;
    [self lua_needLayoutAndSpread];
    self.font = [MLNFont fontWithFontName:nil fontStyle:style fontSize:self.fontSize instance:MLN_KIT_INSTANCE(self.mln_luaCore)];
    [self handleLineSpacing];
}

- (void)lua_fontName:(NSString *)fontName size:(CGFloat)fontSize
{
    MLNCheckStringTypeAndNilValue(fontName)
    if (self.fontSize == fontSize && [self.fontName isEqualToString:fontName]) {
        return;
    }
    [self lua_needLayoutAndSpread];
    self.fontSize = fontSize;
    self.fontName = fontName;
    //获取失败后使用系统默认字体样式
    UIFont *newFont = [UIFont fontWithName:fontName size:fontSize];
    self.font = newFont ?:[UIFont systemFontOfSize:fontSize];
    [self handleLineSpacing];
}

- (void)lua_setFonAutoFit:(BOOL)fit
{
    MLNLuaAssert(self.mln_luaCore, NO, @"Label:setAutoFit method is deprecated!");
    self.autoFit = fit;
    if (fit) {
        [self calculatorAutoSize];
    }
    self.lua_node.enable = NO;
}

- (void)lua_setText:(NSString *)text
{
    if (![text isKindOfClass:[NSString class]]) {
        MLNLuaAssert(self.mln_luaCore, [text isKindOfClass:[NSString class]], @"Error! Cannot assign a non-NSString type to label ");
        return;
    }
    self.text = text;
    [self handleLineSpacing];
}

- (void)lua_setMaxHeight:(CGFloat)maxHeight
{
    _limitMode = MLNLabelMaxModeValue;
    [self setLua_maxHieght:maxHeight];
}

- (void)lua_setMinHeight:(CGFloat)minHeight
{
    _limitMode = MLNLabelMaxModeValue;
    [self setLua_minHeight:minHeight];
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

- (NSString *)mln_handleSingleLineBreakLineWithText:(NSString *)text
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

- (void)mln_handleSingleLineBreakLineWithLine:(NSInteger)line
{
    if (line == 1 && [_originText rangeOfString:@"\n"].location != NSNotFound) {
        [self setText:[_originText stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
    } else if ((self.originText && line != 1) ) {
        [self setText:self.originText];
    }
}

#pragma mark - Overrid For Lua
- (BOOL)lua_canClick
{
    return YES;
}

- (BOOL)lua_canLongPress
{
    return YES;
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

- (void)lua_addSubview:(UIView *)view
{
    MLNLuaAssert(self.mln_luaCore, NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNLuaAssert(self.mln_luaCore, NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNLuaAssert(self.mln_luaCore, NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (UIView *)lua_contentView
{
    return self.innerLabel;
}

- (void)lua_a_setIncludeFontPadding:(BOOL)isIncludepadding
{
    //Android方法 iOS空实现
}

//点击支持
-(void)setOriginString:(MLNStyleString *)originString {
    _originString = originString;
    if (originString) {//add tapgesture
        BOOL needHandle = NO;
        NSDictionary *map = self.originString.styleElementsDictM;
        NSArray *keys = [map allKeys];
        for (NSString *rangeStr in keys) {
            MLNStyleElement *element = map[rangeStr];
            if (element.linkCallBack) {
                needHandle = YES;
                break;
            }
        }
        if (needHandle) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            tap.cancelsTouchesInView = NO;
            [self addGestureRecognizer:tap];
            self.textTap = tap;
        }
    } else {//remove tapgesture
        if (self.textTap) {
            [self removeGestureRecognizer:self.textTap];
        }
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapRecognizer {
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [tapRecognizer locationInView: self];
        [self clickOnStrWithPoint:touchPoint];
    }
}

- (void)clickOnStrWithPoint:(CGPoint)location
{
    if (!CGRectContainsPoint(self.bounds, location)) {
        return ;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat height = CGRectGetHeight(self.innerLabel.bounds);
    CGFloat width = CGRectGetWidth(self.innerLabel.bounds);
    CGPathAddRect(path, NULL, CGRectMake(0.f, 0.f, width, height));
    NSArray *res = MLN_CollectionRunFrame(self.originString.mutableStyledString, path, self.innerLabel.frame.origin);
    if (res.count) {
        NSDictionary *map = _originString.styleElementsDictM;
        NSArray *allKeys = [map allKeys];
        if (allKeys.count) {
            for (MLNRunItem *item in res) {
                if (CGRectContainsPoint(item.frame, location)) {
                    for (NSString *key in allKeys) {
                        NSRange range = NSRangeFromString(key);
                        bool isC = NSRangeContainsRange(range,item.range);
                        if (isC) {
                            NSString *key = NSStringFromRange(range);
                            MLNStyleElement *element = map[key];
                            if (element.linkCallBack) {
                                [element.linkCallBack callIfCan];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    CFRelease(path);
}

NSArray * MLN_CollectionRunFrame(NSMutableAttributedString *aString, CGMutablePathRef path, CGPoint viewOrigin) {
    CTFramesetterRef frameRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)aString);
    CTFrameRef frame = CTFramesetterCreateFrame(frameRef, CFRangeMake(0, aString.length), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    
    CFIndex linesCount = [lines count];
    MLNRunItem *lastItem = nil;
    CTLineRef line = NULL;
    CGFloat lineY = 0;
    NSMutableArray *res = [NSMutableArray array];
    for(CFIndex i = 0; i < linesCount; ++i) {
        line = (__bridge CTLineRef)[lines objectAtIndex:i];
        CGFloat descent, ascent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        lineY = lineY+ascent+descent+leading;
        NSArray *runs = (__bridge NSArray *)CTLineGetGlyphRuns(line);
        CFIndex runsCount = [runs count];
        lastItem = nil;
        CFRelease(line);
        
        for(CFIndex j = 0; j < runsCount; ++j) {
            CTRunRef run = (__bridge CTRunRef)[runs objectAtIndex:j];
            CGRect runFrame = CGRectZero;
            if (lastItem) {
                runFrame.origin.x = CGRectGetMaxX(lastItem.frame);
            }
            if (i != 0) {
                CGFloat tY = lineY-(ascent+descent+leading);
                runFrame.origin.y =  tY > 0 ? tY : 0;
            }
            CGFloat runAscent = 0.0f, runDescent = 0.0f, runLeading = 0.0f;
            //计算得到上下行高、行间距以及CTRun绘制区域宽度
            runFrame.size.width = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
            //计算高度，注意下行高为负数的情况
            CGFloat runHeight = runAscent + fabs(runDescent);
            runFrame.size.height = runHeight;
            CFRange cRange = CTRunGetStringRange(run);
            NSRange range =  NSMakeRange(cRange.location, cRange.length);
            MLNRunItem *item = [MLNRunItem new];
            item.frame = runFrame;
            item.range = range;
            [res addObject:item];
            lastItem = item;
        }
    }
    return res;
}

bool NSRangeContainsRange (NSRange range1, NSRange range2) {
    BOOL retval = NO;
    if (range1.location <= range2.location && range1.location+range1.length >= range2.length+range2.location) {
        retval = YES;;
    }
    
    return retval;
}

#pragma mark - Export To Lua
LUA_EXPORT_VIEW_BEGIN(MLNLabel)
LUA_EXPORT_VIEW_PROPERTY(text, "lua_setText:", "text", MLNLabel)
LUA_EXPORT_VIEW_PROPERTY(textAlign, "setTextAlignment:", "textAlignment", MLNLabel) // MLNTextAlign
LUA_EXPORT_VIEW_PROPERTY(fontSize, "lua_setFontOfSize:", "lua_fontSize", MLNLabel)
LUA_EXPORT_VIEW_PROPERTY(textColor, "setTextColor:", "textColor", MLNLabel)
LUA_EXPORT_VIEW_PROPERTY(lines, "setNumberOfLines:", "numberOfLines", MLNLabel)
LUA_EXPORT_VIEW_PROPERTY(breakMode, "setLineBreakMode:", "lineBreakMode", MLNLabel)
LUA_EXPORT_VIEW_PROPERTY(styleText, "setAttributedText:", "attributedText", MLNLabel)
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPaddingWithTop:right:bottom:left:", MLNLabel)
LUA_EXPORT_VIEW_METHOD(setTextBold, "lua_setTextBold", MLNLabel)
LUA_EXPORT_VIEW_METHOD(setTextFontStyle, "lua_setTextFontStyle:", MLNLabel)
LUA_EXPORT_VIEW_METHOD(fontNameSize, "lua_fontName:size:", MLNLabel)
LUA_EXPORT_VIEW_METHOD(setAutoFit, "lua_setFonAutoFit:", MLNLabel)
LUA_EXPORT_VIEW_METHOD(setWrapContent, "setLua_wrapContent:",MLNLabel) //SDK>=1.0.2
LUA_EXPORT_VIEW_METHOD(setMaxWidth, "setLua_maxWidth:",MLNLabel) //SDK>=1.0.3，自适应时的限制
LUA_EXPORT_VIEW_METHOD(setMinWidth, "setLua_minWidth:",MLNLabel) //SDK>=1.0.3，自适应时的限制
LUA_EXPORT_VIEW_METHOD(setMaxHeight, "lua_setMaxHeight:",MLNLabel) //SDK>=1.0.3，自适应时的限制
LUA_EXPORT_VIEW_METHOD(setMinHeight, "lua_setMinHeight:",MLNLabel) //SDK>=1.0.3，自适应时的限制
LUA_EXPORT_VIEW_METHOD(setLineSpacing, "lua_setLineSpacing:",MLNLabel) //SDK>=1.0.3，自适应时的限制
LUA_EXPORT_VIEW_METHOD(a_setIncludeFontPadding, "lua_a_setIncludeFontPadding:", MLNLabel)
LUA_EXPORT_VIEW_END(MLNLabel, Label, YES, "MLNView", "initWithLuaCore:frame:")
@end
