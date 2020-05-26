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

+ (void)luaui_setText:(NSString *)text
{
    [UIPasteboard generalPasteboard].string = text?:@"";
}

+ (NSString *)luaui_getText
{
    return [UIPasteboard generalPasteboard].string;
}

+ (void)luaui_setText:(NSString *)text clipboardName:(NSString *)name
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

+ (NSString *)luaui_getTextWithClipboardName:(NSString *)name
{
    MLNUIStaticCheckStringTypeAndNilValue(name)
    UIPasteboard *clipboard = nil;
    if (name.length > 0) {
        clipboard = [UIPasteboard pasteboardWithName:name create:NO];
    }
    
    return clipboard.string;
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUIClipboard)
LUAUI_EXPORT_STATIC_METHOD(setText, "luaui_setText:", MLNUIClipboard)
LUAUI_EXPORT_STATIC_METHOD(getText, "luaui_getText", MLNUIClipboard)
LUAUI_EXPORT_STATIC_METHOD(setTextWithClipboardName, "luaui_setText:clipboardName:", MLNUIClipboard)
LUAUI_EXPORT_STATIC_METHOD(getTextWithClipboardName, "luaui_getTextWithClipboardName:", MLNUIClipboard)
LUAUI_EXPORT_STATIC_END(MLNUIClipboard, Clipboard, NO, NULL)
@end
