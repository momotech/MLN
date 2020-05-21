//
//  MLNDataBinding.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import <Foundation/Foundation.h>
#import "MLNKVOObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNDataBinding : NSObject
- (void)bindData:(nullable NSObject *)data forKey:(NSString *)key;
//- (void)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
//- (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (NSArray <NSObject<MLNKVOObserverProtol> *> *)observersForKeyPath:(NSString *)keyPath;
- (void)addObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (void)removeObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
@end

// for array
@interface MLNDataBinding ()
- (void)bindArray:(NSArray *)array forKey:(NSString *)key;
//- (void)addArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forKey:(NSString *)key;
//- (void)removeArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forKey:(NSString *)key;
@end


// for lua
@interface MLNDataBinding ()
- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value;
- (id __nullable)dataForKeyPath:(NSString *)keyPath;
@end



NS_ASSUME_NONNULL_END
