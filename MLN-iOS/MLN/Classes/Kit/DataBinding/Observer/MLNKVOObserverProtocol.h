//
//  MLNKVOObserverProtocol.h
//  Pods
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#ifndef MLNKVOObserverProtocol_h
#define MLNKVOObserverProtocol_h

NS_ASSUME_NONNULL_BEGIN

@protocol MLNKVOObserverProtol <NSObject>

/// 返回持有observer的对象，如果返回nil，则会被MLNDatabinding持有
/// ⚠️ 返回的对象会强持有observer，所以这里要避免循环引用.
//- (nullable NSObject *)objectRetainingObserver;
@property (nonatomic, copy, readonly) NSString *keyPath;
- (void)mln_observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change;

@end


@protocol MLNArrayObserverProtocol <NSObject>
@end


@class MLNDataBinding;
@protocol MLNDataBindingProtocol <NSObject>

@property (nonatomic, strong, readonly) MLNDataBinding * _Nonnull mln_dataBinding;

- (void)bindData:(NSObject *)data forKey:(NSString *)key;

@end

@interface UIViewController (MLNDataBinding)

@property (nonatomic, strong, readonly) MLNDataBinding * _Nonnull mln_dataBinding;
- (void)mln_addToSuperViewController:(UIViewController *_Nonnull)superVC frame:(CGRect) frame;

@end

#define LOCK_INIT() pthread_mutex_init(&_lock, NULL)
#define LOCK_RECURSIVE_INIT() \
    pthread_mutexattr_t mta; \
    pthread_mutexattr_init(&mta); \
    pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE); \
    pthread_mutex_init(&_lock, &mta)
#define LOCK() pthread_mutex_lock(&_lock)
#define UNLOCK() pthread_mutex_unlock(&_lock)
#define LOCK_DESTROY() pthread_mutex_destroy(&_lock)

NS_ASSUME_NONNULL_END

#endif /* MLNKVOObserverProtocol_h */
