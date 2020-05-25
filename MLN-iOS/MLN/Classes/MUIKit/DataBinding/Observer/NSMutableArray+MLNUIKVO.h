//
//  NSMutableArray+MLNUIKVO.h
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//typedef void(^MLNUIKVOObserverHandler)(NSKeyValueChange type, NSMutableArray *newArray, NSDictionary<NSKeyValueChangeKey, id> *change);

typedef void(^MLNUIKVOArrayHandler)(NSMutableArray *array,NSDictionary<NSKeyValueChangeKey, id> *change);
//typedef void(^MLNUIKVOSubcribeArray)(NSDictionary<NSKeyValueChangeKey, id> *change);

@interface NSMutableArray (MLNUIKVO)

- (void)mln_addObserverHandler:(MLNUIKVOArrayHandler)handler;
- (void)mln_removeObserverHandler:(MLNUIKVOArrayHandler)handler;
- (void)mln_clearObserverHandlers;

- (void)mln_startKVO;
- (void)mln_stopKVO;

@end


NS_ASSUME_NONNULL_END
