//
//  MLNObserver.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MLNBlockChange)           (id oldValue, id newValue);

@interface MLNObserver : NSObject

@property (nonatomic, readonly, unsafe_unretained) NSObject *target;
@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, readonly, unsafe_unretained) id owner;
@property (nonatomic, readonly, assign) BOOL attached;

- (instancetype)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath owner:(id)owner;

- (void)attach;
- (void)detach;

- (void)addSettingObservationBlock:(MLNBlockChange)block;

@end

NS_ASSUME_NONNULL_END
