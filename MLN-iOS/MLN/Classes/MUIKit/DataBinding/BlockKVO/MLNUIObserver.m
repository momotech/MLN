//
//  MLNUIObserver.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import "MLNUIObserver.h"
#import <pthread.h>
#import "MLNUIKVOObserverProtocol.h"

@interface MLNUIObserver()
@end

@implementation MLNUIObserver

- (instancetype)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath owner:(id)owner {
    if (self = [super init]) {
        _target = target;
        _keyPath = keyPath;
        _owner = owner;
        _observationBlocks = [NSMutableArray array];
        LOCK_INIT();
    }
    return self;
}

- (void)dealloc {
    [self detach];
    LOCK_DESTROY();
}

- (void)attach {
    self.attached = YES;
}

- (void)detach {
    self.attached = NO;
}

- (void)setAttached:(BOOL)attached {
    if (_attached != attached) {
        _attached = attached;
        if (attached) {
            [self.target addObserver:self
                          forKeyPath:self.keyPath
                             options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                             context:NULL];
        } else {
            [self.target removeObserver:self forKeyPath:self.keyPath];
        }
    }
}

- (void)addObservationBlock:(MLNUIBlockChange)block {
    if (block) {
        LOCK();
        [_observationBlocks addObject:block];
        UNLOCK();
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.target == object && [self.keyPath isEqualToString:keyPath]) {
        BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
        NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        if([NSNull null] == old) old = nil;
        
        id new = [change objectForKey:NSKeyValueChangeNewKey];
        if([NSNull null] == new) new = nil;
        
        __unused NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        if (isPrior) {
            
        } else {
            switch (changeKind) {
                case NSKeyValueChangeSetting:
                    [self executeBlocksWithOld:old new:new change:change];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)executeBlocksWithOld:(id)old new:(id)new change:(NSDictionary *)change{
//    if (old == new || (old && [new isEqual:old])) return;
    LOCK();
    NSArray *copys = _observationBlocks.copy;
    UNLOCK();
    for (MLNUIBlockChange block in copys) {
        block(nil, self.target, old, new, change);
    }
}

@end

