//
//  MLNObserver.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MLNBlockChange)           (id observer, id object, id oldValue, id newValue, NSDictionary<NSKeyValueChangeKey,id> * change);
typedef void(^MLNBlockChangeMany)           (id observer, id object, NSString *keyPath,id oldValue, id newValue, NSDictionary<NSKeyValueChangeKey,id> *change);

@interface MLNObserver : NSObject {
    @protected
    NSMutableArray <MLNBlockChange> *_observationBlocks;
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

- (void)addObservationBlock:(MLNBlockChange)block;

@end

NS_ASSUME_NONNULL_END
