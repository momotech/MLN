//
//  ArgoObserverBase.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/26.
//

#import <Foundation/Foundation.h>
#import "ArgoViewControllerProtocol.h"
#import "ArgoObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//typedef void(^ArgoKVOCallback)(NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> * change);

@interface ArgoObserverBase : NSObject <ArgoObserverProtocol>

@property (nonatomic, weak, readonly) UIViewController <ArgoViewControllerProtocol> *viewController;
@property (nonatomic, copy) ArgoBlockChange callback;
//@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, assign) BOOL active;

- (instancetype)initWithViewController:(nonnull UIViewController<ArgoViewControllerProtocol> *)viewController
                              callback:(nullable ArgoBlockChange)callback
                               keyPath:(nonnull NSString *)keyPath;

- (void)receiveKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
