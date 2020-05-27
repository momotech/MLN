//
//  MLNUIDataBinding.h
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import <Foundation/Foundation.h>
#import "MLNUIKVOObserverProtocol.h"

#define MLNUIKVOOrigin2DArrayKey @"MLNUIKVOOrigin2DArrayKey"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIDataBinding : NSObject
- (void)bindData:(nullable NSObject *)data forKey:(NSString *)key;
//- (void)addDataObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
//- (void)removeDataObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (NSArray <NSObject<MLNUIKVOObserverProtol> *> *)observersForKeyPath:(NSString *)keyPath;
- (NSString *)addMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (void)removeMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
- (void)removeMLNUIObserverByID:(NSString *)observerID;
@end

// for array
@interface MLNUIDataBinding ()
- (void)bindArray:(NSArray *)array forKey:(NSString *)key;
@end

// for lua
@interface MLNUIDataBinding ()
- (id __nullable)dataForKeyPath:(NSString *)keyPath;
- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value;

// keys
- (id __nullable)dataForKeys:(NSArray *)keys;
- (void)updateDataForKeys:(NSArray *)keys value:(id)value;

- (NSString *)addMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeys:(NSArray *)keys;
- (void)removeMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeys:(NSArray *)keys;

//用于判断是否ListView的数据源
- (void)addListViewTag:(NSString *)tag;

@property (nonatomic, strong)void(^errorLog)(NSString *);
@end



NS_ASSUME_NONNULL_END
