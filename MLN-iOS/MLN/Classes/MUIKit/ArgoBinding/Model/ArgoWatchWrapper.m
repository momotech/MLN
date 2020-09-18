//
//  ArgoWatchWrapper.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/3.
//

#import "ArgoWatchWrapper.h"
#import "MLNUIExtScope.h"
#import "ArgoListenerProtocol.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "NSObject+ArgoListener.h"

ArgoFilterBlock kArgoFilter_Lua = ^(ArgoWatchContext context, id value){
    if(context == ArgoWatchContext_Lua)
        return YES;
    return NO;
};

ArgoFilterBlock kArgoFilter_Native = ^(ArgoWatchContext context, id value){
    if(context == ArgoWatchContext_Native)
        return YES;
    return NO;
};

@interface ArgoWatchWrapper ()
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) ArgoFilterBlock filterBlock;
@property (nonatomic, copy) ArgoWatchBlock watchBlock;
@property (nonatomic, weak) ArgoObservableMap *observerd;
@property (nonatomic, strong) id<ArgoListenerToken> token;
@end

@implementation ArgoWatchWrapper

+ (instancetype)wrapperWithKeyPath:(NSString *)keyPath observedObject:(ArgoObservableMap *)observedObject {
    ArgoWatchWrapper *watch = [self new];
    watch.keyPath = keyPath;
    watch.observerd = observedObject;
    return watch;
}

- (ArgoWatchWrapper * _Nonnull (^)(ArgoFilterBlock _Nonnull))filter {
    @weakify(self);
    return ^(ArgoFilterBlock block){
        @strongify(self);
        self.filterBlock = block;
        return self;
    };
}

- (ArgoWatchWrapper * _Nonnull (^)(ArgoWatchBlock _Nonnull))callback {
    @weakify(self);
    return ^(ArgoWatchBlock block){
        @strongify(self);
        self.watchBlock = block;
        if (self.keyPath && block) {
            self.token = [self.observerd addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
                NSObject *old = [change objectForKey:NSKeyValueChangeOldKey];
                NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
//                ArgoWatchContext context = [[change objectForKey:kArgoListenerContext] unsignedIntegerValue];
//                if (self.filterBlock && !self.filterBlock(context, new)) {
//                    return;
//                }
                NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
                
                if (type == NSKeyValueChangeSetting) {
                    block(old, new, self.observerd);
                }
            } forKeyPath:self.keyPath filter:^BOOL(ArgoWatchContext context, NSDictionary *change) {
                NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
                if (self.filterBlock && !self.filterBlock(context, new)) {
                    return NO;
                }
                return YES;
            } triggerWhenAdd:NO];
        }
        return self;
    };
}

- (void)unwatch {
    [self.token removeListener];
}

@end

@interface ArgoWatchArrayWrapper ()
@property (nonatomic, copy) ArgoFilterBlock filterBlock;
@property (nonatomic, weak) ArgoObservableArray *observerd;
@property (nonatomic, strong) id<ArgoListenerToken> token;
@end

@implementation ArgoWatchArrayWrapper

+ (instancetype)wrapperWithObservedObject:(ArgoObservableArray *)observedObject {
    ArgoWatchArrayWrapper *wrap = [ArgoWatchArrayWrapper new];
    wrap.observerd = observedObject;
    return wrap;
}

- (ArgoWatchArrayWrapper * _Nonnull (^)(ArgoFilterBlock _Nonnull))filter {
    @weakify(self);
    return ^(ArgoFilterBlock block){
        @strongify(self);
        self.filterBlock = block;
        return self;
    };
}

- (ArgoWatchArrayWrapper * _Nonnull (^)(ArgoWatchArrayBlock _Nonnull))callback {
    @weakify(self);
    return ^(ArgoWatchArrayBlock block){
        @strongify(self);
        if (block) {
            self.token = [self.observerd addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
//                ArgoWatchContext context = [[change objectForKey:kArgoListenerContext] unsignedIntegerValue];
                block(self.observerd,change);
            } forKeyPath:nil filter:^BOOL(ArgoWatchContext context, NSDictionary *change) {
                NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
                if (self.filterBlock && !self.filterBlock(context, new)) {
                    return NO;
                }
                return YES;
            } triggerWhenAdd:NO];
        }
        return self;
    };
}

- (void)unwatch {
    [self.token removeListener];
}

@end
