//
//  MLNBlockObserver.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNBlockObserver.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"
#import "MLNKitViewController.h"
#import "MLNDataBinding.h"
#import "NSObject+MLNReflect.h"

@interface MLNBlockObserver ()
@property (nonatomic, strong, readwrite) MLNBlock *block;
@end

@implementation MLNBlockObserver

+ (instancetype)observerWithBlock:(MLNBlock *)block keyPath:(nonnull NSString *)keyPath {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([block luaCore]).viewController;
    MLNBlockObserver *observer = [[MLNBlockObserver alloc] initWithViewController:kitViewController callback:nil keyPath:keyPath];
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
        [((id<MLNDataBindingProtocol>)self.viewController).mln_dataBinding removeMLNObserver:self forKeyPath:self.keyPath];
        return;
    }
    
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    
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

    id newValueConvert = [newValue mln_convertToLuaObject];
    id oldValueConvert = [oldValue mln_convertToLuaObject];
    
    [self.block addObjArgument:newValueConvert];
    [self.block addObjArgument:oldValueConvert];
    [self.block callIfCan];
}

- (NSObject *)objectRetainingObserver {
    return self.block.luaCore;
}

- (instancetype)initWithViewController:(UIViewController *)viewController callback:(MLNKVOCallback)callback keyPath:(NSString *)keyPath
{
    self = [super initWithViewController:viewController callback:callback keyPath:keyPath];
    if (self) {
    }
    return self;
}

@end
