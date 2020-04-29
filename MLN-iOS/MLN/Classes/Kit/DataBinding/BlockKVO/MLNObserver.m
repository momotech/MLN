//
//  MLNObserver.m
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import "MLNObserver.h"
@interface MLNObserver()
@property (nonatomic, readwrite, assign) BOOL attached;
@property (nonatomic, strong) NSMutableArray *afterSettingBlocks;
@end

@implementation MLNObserver

- (instancetype)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath owner:(id)owner {
    if (self = [super init]) {
        _target = target;
        _keyPath = keyPath;
        _owner = owner;
        _afterSettingBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self detach];
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

- (void)addSettingObservationBlock:(MLNBlockChange)block {
    if (block) {
        [self.afterSettingBlocks addObject:block];
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
                    [self executeAfterSettingBlocksWithOld:old new:new];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)executeAfterSettingBlocksWithOld:(id)old new:(id)new {
    if (old == new || (old && [new isEqual:old])) return;
    
    for (MLNBlockChange block in self.afterSettingBlocks.copy) {
        block(old, new);
    }
}
@end
