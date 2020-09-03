//
//  ArgoWatchWrapper.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/3.
//

#import "ArgoWatchWrapper.h"
#import "MLNUIExtScope.h"

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
//@property (nonatomic, copy) ArgoWatchBlock callbackBlock;
@property (nonatomic, weak) id<ArgoListenerProtocol> observerd;
@end

@implementation ArgoWatchWrapper

+ (instancetype)wrapperWithKeyPath:(NSString *)keyPath observedObject:(id<ArgoListenerProtocol>)observedObject {
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
        if (self.keyPath && block) {
            [self.observerd addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
                NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
                ArgoWatchContext context = [[change objectForKey:kArgoListenerContext] unsignedIntegerValue];
                if (self.filterBlock && !self.filterBlock(context, new)) {
                    return;
                }
                block(nil, new, self);
            } forKeyPath:self.keyPath];
        }
        return self;
    };
}

@end
