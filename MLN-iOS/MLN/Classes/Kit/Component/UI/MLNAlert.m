//
//  MLNAlert.m
//  
//
//  Created by MoMo on 2018/7/11.
//

#import "MLNAlert.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "MLNBlock.h"

typedef enum : NSUInteger {
    MLNAlertTypeSingle,
    MLNAlertTypeDouble,
    MLNAlertTypeMultiple,
} MLNAlertType;

@interface MLNAlert() <UIAlertViewDelegate>

@property (nonatomic, assign) MLNAlertType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, strong) MLNBlock *cancelCallback;
@property (nonatomic, copy) NSString *sureTitle;
@property (nonatomic, copy) NSArray<NSString *> *multipleTitles;
@property (nonatomic, copy) NSString *singleTitle;
@property (nonatomic, strong) MLNBlock *callback;
@property (nonatomic, weak) UIAlertView *alertView;

@end

@implementation MLNAlert

- (void)lua_setCancel:(NSString *)cancel callback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(cancel, @"string", NSString)
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock)
    self.type = MLNAlertTypeDouble;
    self.cancelTitle = cancel.length > 0?cancel:@"取消";
    self.cancelCallback = callback;
}

- (void)lua_setSure:(NSString *)sure callback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(sure, @"string", NSString)
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock)
    self.type = MLNAlertTypeDouble;
    self.sureTitle = sure.length > 0?sure:@"确认";
    self.callback = callback;
}

- (void)lua_setButtons:(NSArray <NSString *> *)titles callback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(titles, @"Array", [NSMutableArray class])
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock)
    self.type = MLNAlertTypeMultiple;
    self.multipleTitles = titles;
    self.callback = callback;
}

- (void)lua_setSingle:(NSString *)single callback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(single, @"string", [NSMutableArray class])
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock)
    self.type = MLNAlertTypeSingle;
    self.singleTitle = single;
    self.callback = callback;
}

- (void)lua_show
{
    UIAlertView *alertView = nil;
    switch (self.type) {
        case MLNAlertTypeSingle:{
            alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:self.singleTitle otherButtonTitles:nil];
            break;
        }
        case MLNAlertTypeMultiple:{
            MLNLuaAssert(self.mln_luaCore, self.multipleTitles.count >= 1, @"The number of button titles must be no less than one！");
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

- (void)lua_dismiss
{
    if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (self.type) {
        case MLNAlertTypeMultiple:{
            if (self.callback) {
                [self.callback addIntegerArgument:buttonIndex + 1];
                [self.callback callIfCan];
            }
            break;
        }
        case MLNAlertTypeDouble: {
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
LUA_EXPORT_BEGIN(MLNAlert)
LUA_EXPORT_PROPERTY(title, "setTitle:", "title", MLNAlert)
LUA_EXPORT_PROPERTY(message, "setMessage:", "message", MLNAlert)
LUA_EXPORT_METHOD(setCancel, "lua_setCancel:callback:", MLNAlert)
LUA_EXPORT_METHOD(setOk, "lua_setSure:callback:", MLNAlert)
LUA_EXPORT_METHOD(setButtonList, "lua_setButtons:callback:", MLNAlert)
LUA_EXPORT_METHOD(setSingleButton, "lua_setSingle:callback:", MLNAlert)
LUA_EXPORT_METHOD(show, "lua_show", MLNAlert)
LUA_EXPORT_METHOD(dismiss, "lua_dismiss", MLNAlert)
LUA_EXPORT_END(MLNAlert, Alert, NO, NULL, NULL)

@end
