//
//  MLNUITextAlign.m
//  
//
//  Created by MoMo on 2018/7/5.
//

#import "MLNUITextConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUITextConst

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(TextAlign, (@{@"LEFT": @(NSTextAlignmentLeft),
                                    @"CENTER": @(NSTextAlignmentCenter),
                                    @"RIGHT": @(NSTextAlignmentRight)}))
LUAUI_EXPORT_GLOBAL_VAR(BreakMode, (@{@"CHAR_WRAPPING":@(NSLineBreakByCharWrapping),
                                    @"WRAPPING": @(NSLineBreakByWordWrapping),
                                    @"CLIPPING": @(NSLineBreakByClipping),
                                    @"HEAD": @(NSLineBreakByTruncatingHead),
                                    @"TAIL": @(NSLineBreakByTruncatingTail),
                                    @"MIDDLE": @(NSLineBreakByTruncatingMiddle)}))
LUAUI_EXPORT_GLOBAL_VAR(FontStyle, (@{@"NORMAL": @(MLNUIFontStyleDefault),//正常
                                    @"BOLD": @(MLNUIFontStyleBold),//斜体
                                    @"ITALIC": @(MLNUIFontStyleItalic),//倾斜
                                    @"BOLD_ITALIC": @(MLNUIFontStyleBoldItalic)}))
LUAUI_EXPORT_GLOBAL_VAR(UnderlineStyle, (@{@"NONE": @(MLNUIUnderlineStyleNone),
                                         @"LINE": @(MLNUIUnderlineStyleSingle)}))
LUAUI_EXPORT_GLOBAL_VAR_END()

@end
