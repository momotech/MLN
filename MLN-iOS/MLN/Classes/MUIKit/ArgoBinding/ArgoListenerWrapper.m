//
//  ArgoListenerWrapper.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import "ArgoListenerWrapper.h"
#import "ArgoListenerProtocol.h"

@implementation ArgoListenerWrapper

//+ (instancetype)wrapperWithID:(NSInteger)obID block:(ArgoBlockChange)block observedObject:(id<ArgoListenerProtocol>)observed keyPath:(NSString *)keyPath key:(NSString *)key prefix:(nonnull NSString *)prefix {
//    ArgoListenerWrapper *wrapper = [ArgoListenerWrapper new];
//    wrapper.obID = obID;
//    wrapper.block = block;
//    wrapper.keyPath = keyPath;
//    wrapper.observedObject = observed;
//    wrapper.key = key;
////    wrapper.prefix = prefix;
//    return wrapper;
//}

+ (instancetype)wrapperWithID:(NSInteger)obID block:(ArgoBlockChange)block observedObject:(id<ArgoListenerProtocol>)observed keyPath:(NSString *)keyPath key:(NSString *)key {
    ArgoListenerWrapper *wrapper = [ArgoListenerWrapper new];
    wrapper.obID = obID;
    wrapper.block = block;
    wrapper.keyPath = keyPath;
    wrapper.observedObject = observed;
    wrapper.key = key;
    return wrapper;
}

- (void)cancel {
    _cancel = YES;
//    self.observedObject = nil;
    self.block = nil;
}

- (BOOL)isCanceld {
    return _cancel;
}

- (BOOL)isEqual:(ArgoListenerWrapper *)object {
    if (![object isKindOfClass:[ArgoListenerWrapper class]]) {
        return NO;
    }
    return self.obID == object.obID && self.block == object.block && [self.key isEqualToString:object.key];
}

@end
