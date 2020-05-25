//
//  MLNUISwitch.m
//
//
//  Created by MoMo on 2018/12/18.
//

#import "MLNUISwitch.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"

@interface MLNUISwitchActionHandler : NSObject

@end

@implementation MLNUISwitchActionHandler

- (void)switchAction:(MLNUISwitch *)sender
{
    if (sender.switchChangedCallback) {
        [sender.switchChangedCallback addBOOLArgument:sender.on];
        [sender.switchChangedCallback callIfCan];
    }
}

@end


@interface MLNUISwitch()

@property (nonatomic, strong) MLNUISwitchActionHandler *switchHandler;

@end

@implementation MLNUISwitch

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSwitchObserver];
    }
    return self;
}

- (void)lua_setOn:(BOOL)on
{
    [self setOn:on animated:YES];
}

- (BOOL)lua_on
{
    return self.isOn;
}

- (void)lua_setSwitchChangedCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.switchChangedCallback = callback;
}

#pragma mark - private methoc
- (void)addSwitchObserver
{
    [self addTarget:self.switchHandler action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (MLNUISwitchActionHandler *)switchHandler
{
    if (!_switchHandler) {
        _switchHandler = [[MLNUISwitchActionHandler alloc] init];
    }
    return _switchHandler;
}

#pragma mark - Override
- (void)lua_addSubview:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNUIKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNUIKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUISwitch)
LUA_EXPORT_PROPERTY(on, "lua_setOn:", "lua_on", MLNUISwitch)
LUA_EXPORT_VIEW_METHOD(setSwitchChangedCallback, "lua_setSwitchChangedCallback:", MLNUISwitch)
LUA_EXPORT_VIEW_END(MLNUISwitch, Switch, YES, "MLNUIView", NULL)

@end
