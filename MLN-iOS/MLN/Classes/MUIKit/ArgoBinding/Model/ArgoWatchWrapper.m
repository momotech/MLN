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

@implementation ArgoWatchWrapper

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
        if (self && block && self.keyPath) {
            [self.observerd addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
                NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
                block(nil, new, self);
            } forKeyPath:self.keyPath];
        }
        return self;
    };
}

@end
