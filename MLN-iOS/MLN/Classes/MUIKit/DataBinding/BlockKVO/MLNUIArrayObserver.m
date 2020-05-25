//
//  MLNUIArrayObserver.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/30.
//

#import "MLNUIArrayObserver.h"
#import "NSArray+MLNUIKVO.h"
#import "NSMutableArray+MLNUIKVO.h"
#import "MLNUIKVOObserverProtocol.h"
#import "MLNUIExtScope.h"

@interface MLNUIArrayObserver ()
@property (nonatomic, strong) MLNUIKVOArrayHandler handler;
@end

@implementation MLNUIArrayObserver

- (instancetype)initWithTarget:(NSMutableArray *)target keyPath:(NSString *)keyPath owner:(id)owner {
    NSParameterAssert([target isKindOfClass:[NSMutableArray class]]);
    return [super initWithTarget:target keyPath:keyPath owner:owner];
}

- (void)attach {
    [self setAttached:YES];
}

- (void)detach {
    [self setAttached:NO];
}

- (void)setAttached:(BOOL)attached {
    if (_attached != attached) {
        _attached = attached;
        NSMutableArray *arr = (NSMutableArray *)self.target;
        if (attached) {
            @weakify(self);
            self.handler = ^(NSMutableArray * _Nonnull array, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                @strongify(self);
                [self executeBlocks:change];
            };
            [arr mln_startKVO];
            [arr mln_addObserverHandler:self.handler];
        } else {
            [arr mln_removeObserverHandler:self.handler];
        }
    }
}

- (void)executeBlocks:(NSDictionary *)change {
    LOCK();
    NSArray <MLNUIBlockChange> *copys = _observationBlocks.copy;
    UNLOCK();
    [copys enumerateObjectsUsingBlock:^(MLNUIBlockChange  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id new = change[NSKeyValueChangeNewKey];
        if (new == [NSNull null]) new = nil;

        id old = change[NSKeyValueChangeOldKey];
        if (old == [NSNull null]) old = nil;
        
        obj(nil, self.target,old, new, change);
    }];
}

@end
