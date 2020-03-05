//
//  MLNBlockObserver.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNBlockObserver.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"
#import "MLNKitViewController.h"
#import "MLNKitViewController+DataBinding.h"
#import "KVOController.h"

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
        [(MLNKitViewController *)self.viewController removeDataObserver:self forKeyPath:self.keyPath];
        return;
    }
    
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];

    [self.block addObjArgument:newValue];
    [self.block addObjArgument:oldValue];
    [self.block callIfCan];
}

- (NSObject *)objectRetainingObserver {
    return self.block.luaCore;
}

@end
