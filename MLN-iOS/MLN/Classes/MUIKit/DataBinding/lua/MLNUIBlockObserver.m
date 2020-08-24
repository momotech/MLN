//
//  MLNUIBlockObserver.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNUIBlockObserver.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "MLNUIDataBinding.h"
#import "NSObject+MLNUIReflect.h"
#import "MLNUIMetamacros.h"
#import "MLNUIBlock+LazyCall.h"

@interface MLNUIBlockObserver ()
@property (nonatomic, strong, readwrite) MLNUIBlock *block;
@end

@implementation MLNUIBlockObserver

+ (instancetype)observerWithBlock:(MLNUIBlock *)block keyPath:(nonnull NSString *)keyPath {
    UIViewController *kitViewController = (UIViewController *)MLNUI_KIT_INSTANCE([block luaCore]).viewController;
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
        [((id<MLNUIDataBindingProtocol>)self.viewController).mlnui_dataBinding removeMLNUIObserverByID:self.obID];
        return;
    }
    
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    
    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
    NSUInteger index = indexSet.firstIndex;
    
    switch (type) {
        case NSKeyValueChangeInsertion: {
            NSMutableArray *oldArray = [object mutableCopy];
            if (newValue) {
                if (index < oldArray.count) {
                    [oldArray removeObjectAtIndex:index];
                }
#if DEBUG
                else {
                    NSAssert(NO, @"index error ",index);
                }
#endif
//                    [oldArray removeObject:newValue];
            }
            newValue = object;
            oldValue = oldArray;
        }
            break;
        case NSKeyValueChangeRemoval: {
            NSMutableArray *oldArray = [object mutableCopy];
            if (oldValue) {
                if (index == oldArray.count) {
                    [oldArray addObject:oldValue];
                } else if(index < oldArray.count) {
                    [oldArray insertObject:oldValue atIndex:index];
                }
#if DEBUG
                else {
                    NSAssert(NO, @"index error ",index);
                    
                }
#endif
            }
            newValue = object;
            oldValue = oldArray;
        }
            break;
        case NSKeyValueChangeReplacement: {
            NSMutableArray *oldArray = [object mutableCopy];
            if (oldValue) {
                if (index == oldArray.count) {
                    [oldArray addObject:oldValue];
                } else if(index < oldArray.count) {
                    [oldArray replaceObjectAtIndex:index withObject:oldValue];
                }
#if DEBUG
                else {
                    NSAssert(NO, @"index error ",index);
                }
#endif
            }
            newValue = object;
            oldValue = oldArray;
        }
            break;
        default:
            break;
    }

    id tmp = [change objectForKey:MLNUIKVOOrigin2DArrayKey]; // 2D数组
    if (tmp && tmp != object) {
        newValue = tmp;
        oldValue = nil;
    }
    
    id newValueConvert = [newValue mlnui_convertToLuaObject];
    id oldValueConvert = [oldValue mlnui_convertToLuaObject];
    
    [self.block addObjArgument:newValueConvert];
//    [self.block addObjArgument:oldValueConvert];
    [self.block lazyCallIfCan:nil];
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
