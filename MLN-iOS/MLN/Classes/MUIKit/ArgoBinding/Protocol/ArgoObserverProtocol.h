//
//  ArgoObserverProtocol.h
//  Pods
//
//  Created by Dongpeng Dai on 2020/8/29.
//

#ifndef ArgoObserverProtocol_h
#define ArgoObserverProtocol_h
#import "ArgoListenerProtocol.h"

@protocol ArgoObserverProtocol <NSObject>

@property (nonatomic, copy, readonly)NSString *keyPath;

- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change;

@end

#endif /* ArgoObserverProtocol_h */
