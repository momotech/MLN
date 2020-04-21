//
//  MLNKVOObserverProtocol.h
//  Pods
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#ifndef MLNKVOObserverProtocol_h
#define MLNKVOObserverProtocol_h

@protocol MLNKVOObserverProtol <NSObject>

/// 返回持有observer的对象，如果返回nil，则会被MLNDatabinding持有
/// ⚠️ 返回的对象会强持有observer，所以这里要避免循环引用.
//- (nullable NSObject *)objectRetainingObserver;

- (void)mln_observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change;

@end


@protocol MLNArrayObserverProtocol <NSObject>
@end

@class MLNDataBinding;
@interface UIViewController (MLNDataBinding)
@property (nonatomic, strong, readonly) MLNDataBinding * _Nonnull mln_dataBinding;
- (void)mln_addToSuperViewController:(UIViewController *_Nonnull)superVC frame:(CGRect) frame;

@end

#define LOCK_INIT() pthread_mutex_init(&_lock, NULL)
#define LOCK() pthread_mutex_lock(&_lock)
#define UNLOCK() pthread_mutex_unlock(&_lock)
#define LOCK_DESTROY() pthread_mutex_destroy(&_lock)

#endif /* MLNKVOObserverProtocol_h */
