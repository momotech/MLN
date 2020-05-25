//
//  MLNDataBinding.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import <Foundation/Foundation.h>
#import "MLNKVOObserverProtocol.h"

#define MLNKVOOrigin2DArrayKey @"MLNKVOOrigin2DArrayKey"

NS_ASSUME_NONNULL_BEGIN

@interface MLNDataBinding : NSObject
- (void)bindData:(nullable NSObject *)data forKey:(NSString *)key;
//- (void)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
//- (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (NSArray <NSObject<MLNKVOObserverProtol> *> *)observersForKeyPath:(NSString *)keyPath;
- (NSString *)addMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (void)removeMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (void)removeMLNObserverByID:(NSString *)observerID;
@end

// for array
@interface MLNDataBinding ()
- (void)bindArray:(NSArray *)array forKey:(NSString *)key;
@end

// for lua
@interface MLNDataBinding ()
- (id __nullable)dataForKeyPath:(NSString *)keyPath;
- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value;

// keys
- (id __nullable)dataForKeys:(NSArray *)keys;
- (void)updateDataForKeys:(NSArray *)keys value:(id)value;

- (NSString *)addMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeys:(NSArray *)keys;
- (void)removeMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeys:(NSArray *)keys;

@end



NS_ASSUME_NONNULL_END
