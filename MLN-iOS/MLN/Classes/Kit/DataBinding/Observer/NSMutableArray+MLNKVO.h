//
//  NSMutableArray+MLNKVO.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//typedef void(^MLNKVOObserverHandler)(NSKeyValueChange type, NSMutableArray *newArray, NSDictionary<NSKeyValueChangeKey, id> *change);

typedef void(^MLNKVOArrayHandler)(NSMutableArray *array,NSDictionary<NSKeyValueChangeKey, id> *change);

@interface NSMutableArray (MLNKVO)

- (void)mln_addObserverHandler:(MLNKVOArrayHandler)handler;
- (void)mln_removeObserverHandler:(MLNKVOArrayHandler)handler;
- (void)mln_clearObserverHandlers;

- (void)mln_startKVO;
- (void)mln_stopKVO;

@end


NS_ASSUME_NONNULL_END
