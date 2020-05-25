//
//  MLNUIClipboard.m
//
//
//  Created by MoMo on 2019/7/5.
//

#import "MLNUIClipboard.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIKitHeader.h"

@implementation MLNUIClipboard

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
    MLNUIStaticCheckStringTypeAndNilValue(text)
    MLNUIStaticCheckStringTypeAndNilValue(name)
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
    MLNUIStaticCheckStringTypeAndNilValue(name)
    UIPasteboard *clipboard = nil;
    if (name.length > 0) {
        clipboard = [UIPasteboard pasteboardWithName:name create:NO];
    }
    
    return clipboard.string;
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNUIClipboard)
LUA_EXPORT_STATIC_METHOD(setText, "lua_setText:", MLNUIClipboard)
LUA_EXPORT_STATIC_METHOD(getText, "lua_getText", MLNUIClipboard)
LUA_EXPORT_STATIC_METHOD(setTextWithClipboardName, "lua_setText:clipboardName:", MLNUIClipboard)
LUA_EXPORT_STATIC_METHOD(getTextWithClipboardName, "lua_getTextWithClipboardName:", MLNUIClipboard)
LUA_EXPORT_STATIC_END(MLNUIClipboard, Clipboard, NO, NULL)
@end
