//
//  MLNClipboard.m
//
//
//  Created by MoMo on 2019/7/5.
//

#import "MLNClipboard.h"
#import "MLNStaticExporterMacro.h"

@implementation MLNClipboard

+ (void)lua_setText:(NSString *)text
{
    [UIPasteboard generalPasteboard].string = text?:@"";
}

+ (NSString *)lua_getText
{
    return [UIPasteboard generalPasteboard].string;
}

+ (void)lua_setText:(NSString *)text clipboardName:(NSString *)name
{
    UIPasteboard *clipboard = nil;
    if (name.length > 0) {
        clipboard = [UIPasteboard pasteboardWithName:name create:YES];
    } else {
        clipboard = [UIPasteboard generalPasteboard];
    }
    
     clipboard.string = text;
}

+ (NSString *)lua_getTextWithClipboardName:(NSString *)name
{
    UIPasteboard *clipboard = nil;
    if (name.length > 0) {
        clipboard = [UIPasteboard pasteboardWithName:name create:NO];
    }
    
    return clipboard.string;
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNClipboard)
LUA_EXPORT_STATIC_METHOD(setText, "lua_setText:", MLNClipboard)
LUA_EXPORT_STATIC_METHOD(getText, "lua_getText", MLNClipboard)
LUA_EXPORT_STATIC_METHOD(setTextWithClipboardName, "lua_setText:clipboardName:", MLNClipboard)
LUA_EXPORT_STATIC_METHOD(getTextWithClipboardName, "lua_getTextWithClipboardName:", MLNClipboard)
LUA_EXPORT_STATIC_END(MLNClipboard, Clipboard, NO, NULL)
@end
