//
//  MLNUIAlert.m
//  
//
//  Created by MoMo on 2018/7/11.
//

#import "MLNUIAlert.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIBlock.h"

typedef enum : NSUInteger {
    MLNUIAlertTypeSingle,
    MLNUIAlertTypeDouble,
    MLNUIAlertTypeMultiple,
} MLNUIAlertType;

@interface MLNUIAlert() <UIAlertViewDelegate>

@property (nonatomic, assign) MLNUIAlertType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, strong) MLNUIBlock *cancelCallback;
@property (nonatomic, copy) NSString *sureTitle;
@property (nonatomic, copy) NSArray<NSString *> *multipleTitles;
@property (nonatomic, copy) NSString *singleTitle;
@property (nonatomic, strong) MLNUIBlock *callback;
@property (nonatomic, weak) UIAlertView *alertView;

@end

@implementation MLNUIAlert

- (void)luaui_setCancel:(NSString *)cancel callback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(cancel, @"string", NSString)
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock)
    self.type = MLNUIAlertTypeDouble;
    self.cancelTitle = cancel.length > 0?cancel:@"取消";
    self.cancelCallback = callback;
}

- (void)luaui_setSure:(NSString *)sure callback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(sure, @"string", NSString)
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock)
    self.type = MLNUIAlertTypeDouble;
    self.sureTitle = sure.length > 0?sure:@"确认";
    self.callback = callback;
}

- (void)luaui_setButtons:(NSArray <NSString *> *)titles callback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(titles, @"Array", [NSMutableArray class])
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock)
    MLNUILuaAssert(self.mlnui_luaCore, titles && titles.count > 1, @"The number of button titles must be no less than one！");
    self.type = MLNUIAlertTypeMultiple;
    self.multipleTitles = titles;
    self.callback = callback;
}

- (void)luaui_setSingle:(NSString *)single callback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(single, @"string", [NSMutableArray class])
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock)
    self.type = MLNUIAlertTypeSingle;
    self.singleTitle = single;
    self.callback = callback;
}

- (void)luaui_show
{
    UIAlertView *alertView = nil;
    switch (self.type) {
        case MLNUIAlertTypeSingle:{
            alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:self.singleTitle otherButtonTitles:nil];
            break;
        }
        case MLNUIAlertTypeMultiple:{
            MLNUILuaAssert(self.mlnui_luaCore, self.multipleTitles.count > 1, @"The number of button titles must be no less than one！");
            alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            for (NSString *title in self.multipleTitles) {
                [alertView addButtonWithTitle:title];
            }
            break;
        }
        default:
            alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:self.cancelTitle otherButtonTitles:self.sureTitle, nil];
            break;
    }
    _alertView = alertView;
    [alertView show];
    
}

- (void)luaui_dismiss
{
    if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (self.type) {
        case MLNUIAlertTypeMultiple:{
            if (self.callback) {
                [self.callback addIntegerArgument:buttonIndex + 1];
                [self.callback callIfCan];
            }
            break;
        }
        case MLNUIAlertTypeDouble: {
            switch (buttonIndex) {
                case 0:
                    if (_cancelCallback) {
                        [_cancelCallback callIfCan];
                    }
                    break;
                case 1:
                    if (_callback) {
                        [_callback callIfCan];
                    }
                    break;
                default:
                    break;
            }
        }
        break;
        default:{
            if (self.callback) {
                [self.callback callIfCan];
            }
            break;
        }
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.cancelCallback) {
        [self.cancelCallback callIfCan];
    }
}

#pragma mark - Export For Lua
LUAUI_EXPORT_BEGIN(MLNUIAlert)
LUAUI_EXPORT_PROPERTY(title, "setTitle:", "title", MLNUIAlert)
LUAUI_EXPORT_PROPERTY(message, "setMessage:", "message", MLNUIAlert)
LUAUI_EXPORT_METHOD(setCancel, "luaui_setCancel:callback:", MLNUIAlert)
LUAUI_EXPORT_METHOD(setOk, "luaui_setSure:callback:", MLNUIAlert)
LUAUI_EXPORT_METHOD(setButtonList, "luaui_setButtons:callback:", MLNUIAlert)
LUAUI_EXPORT_METHOD(setSingleButton, "luaui_setSingle:callback:", MLNUIAlert)
LUAUI_EXPORT_METHOD(show, "luaui_show", MLNUIAlert)
LUAUI_EXPORT_METHOD(dismiss, "luaui_dismiss", MLNUIAlert)
LUAUI_EXPORT_END(MLNUIAlert, Alert, NO, NULL, NULL)

@end
