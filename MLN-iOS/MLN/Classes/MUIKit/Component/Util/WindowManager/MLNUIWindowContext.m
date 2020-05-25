//
//  MLNUIWindowContext.m
//
//
//  Created by MoMo on 2019/4/29.
//

#import "MLNUIWindowContext.h"

@interface MLNUIWindowContext()

@property (nonatomic, strong) NSPointerArray *windowsArray;

@end

@implementation MLNUIWindowContext

static MLNUIWindowContext *_context;

+ (instancetype)sharedContext
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _context = [[MLNUIWindowContext alloc] init];
    });
    return _context;
}

- (void)pushKeyWindow:(UIWindow *)keyWindow
{
    if (keyWindow) {
        [self removeWithWindow:keyWindow];
        [self.windowsArray addPointer:(__bridge void *)(keyWindow)];
    }
}

- (UIWindow *)popKeyWindow
{
    if (self.windowsArray.allObjects.count >= 1) {
        UIWindow *window = nil;
        for (NSInteger index = self.windowsArray.count - 1; index >= 0; index--) {
            window = [self.windowsArray pointerAtIndex:index];
            if (window) {
                [self.windowsArray removePointerAtIndex:index];
                break;
            }
        }
        return window;
    }
    return nil;
}

- (UIWindow *)topWindow
{
    if (self.windowsArray.allObjects.count >= 1) {
        UIWindow *window = nil;
        for (NSInteger index = self.windowsArray.count - 1; index >= 0; index--) {
            window = [self.windowsArray pointerAtIndex:index];
            if (window) {
                break;
            }
        }
        return window;
    }
    return nil;
}

- (void)removeWithWindow:(UIWindow *)keyWindow
{
    NSInteger index = 0;
    for (UIWindow *window in self.windowsArray) {
        if (window == keyWindow) {
            [self.windowsArray removePointerAtIndex:index];
            break;
        }
        index++;
    }
}



#pragma makr - getter
- (NSPointerArray *)windowsArray
{
    if (!_windowsArray) {
        _windowsArray = [NSPointerArray weakObjectsPointerArray];
    }
    return _windowsArray;
}

- (NSArray *)allObject
{
    return self.windowsArray.allObjects;
}

@end
