//
//  MLNUIObserver.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MLNUIBlockChange)           (id observer, id object, id oldValue, id newValue, NSDictionary<NSKeyValueChangeKey,id> * change);
typedef void(^MLNUIBlockChangeMany)           (id observer, id object, NSString *keyPath,id oldValue, id newValue, NSDictionary<NSKeyValueChangeKey,id> *change);

@interface MLNUIObserver : NSObject {
    @protected
    NSMutableArray <MLNUIBlockChange> *_observationBlocks;
    pthread_mutex_t _lock;
    BOOL _attached;
}

@property (nonatomic, readonly, unsafe_unretained) NSObject *target;
@property (nonatomic, readonly, unsafe_unretained) id owner;
@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, assign, readonly) BOOL attached;

- (instancetype)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath owner:(id)owner;

- (void)attach;
- (void)detach;

- (void)addObservationBlock:(MLNUIBlockChange)block;

@end

NS_ASSUME_NONNULL_END
