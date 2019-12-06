//
//  MLNSwitch.m
//
//
//  Created by MoMo on 2018/12/18.
//

#import "MLNSwitch.h"
#import "MLNViewExporterMacro.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"

@interface MLNSwitchActionHandler : NSObject

@end

@implementation MLNSwitchActionHandler

- (void)switchAction:(MLNSwitch *)sender
{
    if (sender.switchChangedCallback) {
        [sender.switchChangedCallback addBOOLArgument:sender.on];
        [sender.switchChangedCallback callIfCan];
    }
}

@end


@interface MLNSwitch()

@property (nonatomic, strong) MLNSwitchActionHandler *switchHandler;

@end

@implementation MLNSwitch

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

- (void)lua_setSwitchChangedCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.switchChangedCallback = callback;
}

#pragma mark - private methoc
- (void)addSwitchObserver
{
    [self addTarget:self.switchHandler action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (MLNSwitchActionHandler *)switchHandler
{
    if (!_switchHandler) {
        _switchHandler = [[MLNSwitchActionHandler alloc] init];
    }
    return _switchHandler;
}

#pragma mark - Override
- (void)lua_addSubview:(UIView *)view
{
    MLNKitLuaAssert(NO, @"Not found \"addView\" method, just continar of View has it!");
}

- (void)lua_insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    MLNKitLuaAssert(NO, @"Not found \"insertView\" method, just continar of View has it!");
}

- (void)lua_removeAllSubViews
{
    MLNKitLuaAssert(NO, @"Not found \"removeAllSubviews\" method, just continar of View has it!");
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNSwitch)
LUA_EXPORT_PROPERTY(on, "lua_setOn:", "lua_on", MLNSwitch)
LUA_EXPORT_VIEW_METHOD(setSwitchChangedCallback, "lua_setSwitchChangedCallback:", MLNSwitch)
LUA_EXPORT_VIEW_END(MLNSwitch, Switch, YES, "MLNView", NULL)

@end
