//
//  MLNKVOObserver.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import <Foundation/Foundation.h>
#import "MLNKVOObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNBlock;
typedef void(^MLNKVOCallback)(NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> * change);

@interface MLNKVOObserver : NSObject <MLNKVOObserverProtol>
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, copy, readonly) NSString *keyPath;
@property (nonatomic, weak, readonly) UIViewController *viewController;

- (instancetype)initWithViewController:(nullable UIViewController *)viewController
                              callback:(nullable MLNKVOCallback)callback
                               keyPath:(NSString  *)keyPath NS_DESIGNATED_INITIALIZER;

- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change NS_REQUIRES_SUPER ;

@end

NS_ASSUME_NONNULL_END
