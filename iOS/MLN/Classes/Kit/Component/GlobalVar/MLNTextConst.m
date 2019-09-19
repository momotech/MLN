//
//  MLNTextAlign.m
//  
//
//  Created by MoMo on 2018/7/5.
//

#import "MLNTextConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNTextConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(TextAlign, (@{@"LEFT": @(NSTextAlignmentLeft),
                                    @"CENTER": @(NSTextAlignmentCenter),
                                    @"RIGHT": @(NSTextAlignmentRight)}))
LUA_EXPORT_GLOBAL_VAR(BreakMode, (@{@"CHAR_WRAPPING":@(NSLineBreakByCharWrapping),
                                    @"WRAPPING": @(NSLineBreakByWordWrapping),
                                    @"CLIPPING": @(NSLineBreakByClipping),
                                    @"HEAD": @(NSLineBreakByTruncatingHead),
                                    @"TAIL": @(NSLineBreakByTruncatingTail),
                                    @"MIDDLE": @(NSLineBreakByTruncatingMiddle)}))
LUA_EXPORT_GLOBAL_VAR(FontStyle, (@{@"NORMAL": @(MLNFontStyleDefault),//正常
                                    @"BOLD": @(MLNFontStyleBold),//斜体
                                    @"ITALIC": @(MLNFontStyleItalic),//倾斜
                                    @"BOLD_ITALIC": @(MLNFontStyleBoldItalic)}))
LUA_EXPORT_GLOBAL_VAR(UnderlineStyle, (@{@"NONE": @(MLNUnderlineStyleNone),
                                         @"LINE": @(MLNUnderlineStyleSingle)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
