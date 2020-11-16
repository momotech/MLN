//
//  ArgoLuaObserver.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/29.
//

#import "ArgoLuaObserver.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "NSObject+MLNUIReflect.h"
#import "MLNUIMetamacros.h"
#import "MLNUIBlock+LazyCall.h"
#import "NSObject+ArgoListener.h"

@interface ArgoLuaObserver ()
@property (nonatomic, strong, readwrite) MLNUIBlock *block;
@end

@implementation ArgoLuaObserver

+ (instancetype)observerWithBlock:(MLNUIBlock *)block callback:(ArgoBlockChange)callback keyPath:(NSString *)keyPath {
        UIViewController<ArgoViewControllerProtocol> *vc = (UIViewController <ArgoViewControllerProtocol>*)MLNUI_KIT_INSTANCE([block luaCore]).viewController;
        ArgoLuaObserver *observer = [[self alloc] initWithViewController:vc callback:callback keyPath:keyPath];
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

- (void)receiveKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change {
    [super receiveKeyPath:keyPath ofObject:object change:change];
    if (!self.block.luaCore) {
        //TODO: remove observer？
//        [((id<MLNUIDataBindingProtocol>)self.viewController).mlnui_dataBinding removeMLNUIObserverByID:self.obID];
        return;
    }
    
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        
    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
//        NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
//        NSUInteger index = indexSet.firstIndex;
    
    switch (type) {
        case NSKeyValueChangeInsertion:
        case NSKeyValueChangeRemoval:
        case NSKeyValueChangeReplacement: {
            newValue = [change objectForKey:kArgoListenerChangedObject];
            NSString *key = [change objectForKey:kArgoListenerChangedKey];
            if ([key isEqualToString:kArgoListenerArrayPlaceHolder_SUPER_IS_2D]) {
                newValue = [object argoGetForKeyPath:keyPath];
            }
        }
            break;
        default:
            break;
    }

    id newValueConvert = [newValue mlnui_convertToLuaObject];
//    id oldValueConvert = [oldValue mlnui_convertToLuaObject];
    [self.block addObjArgument:newValueConvert];
    //    [self.block addObjArgument:oldValueConvert];
//    [self.block lazyCallIfCan:nil];
    [self.block callIfCan];
}

@end
