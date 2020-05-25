//
//  MLNUIBlockObserver.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNUIBlockObserver.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitViewController.h"
#import "MLNUIDataBinding.h"
#import "NSObject+MLNUIReflect.h"

@interface MLNUIBlockObserver ()
@property (nonatomic, strong, readwrite) MLNUIBlock *block;
@end

@implementation MLNUIBlockObserver

+ (instancetype)observerWithBlock:(MLNUIBlock *)block keyPath:(nonnull NSString *)keyPath {
    MLNUIKitViewController *kitViewController = (MLNUIKitViewController *)MLNUI_KIT_INSTANCE([block luaCore]).viewController;
    MLNUIBlockObserver *observer = [[MLNUIBlockObserver alloc] initWithViewController:kitViewController callback:nil keyPath:keyPath];
    observer.block = block;
    
    // hotreload时有问题，所以改成在notify时进行移除.
//    __weak typeof (kitViewController) weakKit = kitViewController;
//    [kitViewController.kitInstance addOnDestroyCallback:^{
//        __strong typeof (kitViewController) strongKit = weakKit;
//        if (block.luaCore == strongKit.kitInstance.luaCore) {
//            [strongKit removeDataObserver:observer forKeyPath:keyPath];
//        }
//    }];
    
    return observer;
}

// eg: 这里的keypath是text, self.keyPath是userData.text
- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    [super notifyKeyPath:keyPath ofObject:object change:change];
    if (!self.block.luaCore) {
        [((id<MLNUIDataBindingProtocol>)self.viewController).mln_dataBinding removeMLNUIObserver:self forKeyPath:self.keyPath];
        return;
    }
    
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    
    id tmp = [change objectForKey:MLNUIKVOOrigin2DArrayKey]; // 2D数组
    if (tmp) {
        newValue = tmp;
        oldValue = nil;
    } else {
        NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        switch (type) {
            case NSKeyValueChangeInsertion:
            case NSKeyValueChangeRemoval:
            case NSKeyValueChangeReplacement:
                newValue = object;
                oldValue = nil;
                break;
            default:
                break;
        }
    }

    id newValueConvert = [newValue mln_convertToLuaObject];
    id oldValueConvert = [oldValue mln_convertToLuaObject];
    
    [self.block addObjArgument:newValueConvert];
    [self.block addObjArgument:oldValueConvert];
    [self.block callIfCan];
}

- (NSObject *)objectRetainingObserver {
    return self.block.luaCore;
}

- (instancetype)initWithViewController:(UIViewController *)viewController callback:(MLNUIKVOCallback)callback keyPath:(NSString *)keyPath
{
    self = [super initWithViewController:viewController callback:callback keyPath:keyPath];
    if (self) {
    }
    return self;
}

@end
