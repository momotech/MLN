//
//  ArgoListenerToken.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import "ArgoListenerToken.h"
#import "NSObject+ArgoListener.h"

@interface ArgoListenerToken ()

@end

@implementation ArgoListenerToken

//- (void)removeObserver {
//    for (ArgoListenerWrapper *wrap in self.wrappers) {
//        if (![wrap isCanceld]) {
//            [wrap.observedObject removeArgoListenerWrapper:wrap];
//        }
//    }
//}

- (void)removeListener {
    [self.observedObject removeArgoListenerWithToken:self];
}

@end
