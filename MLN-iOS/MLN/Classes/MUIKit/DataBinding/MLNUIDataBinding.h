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
//- (NSArray <NSObject<MLNUIKVOObserverProtol> *> *)dataObserversForKeyPath:(NSString *)keyPath;
//- (NSArray <NSObject<MLNUIKVOObserverProtol> *> *)arrayObserversForKeyPath:(NSString *)keyPath;

- (NSString *)addMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
//- (void)removeMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;
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
//- (id __nullable)dataForKeys:(NSArray *)keys;
- (id __nullable)dataForKeys:(NSArray *)keys frontValue:(NSObject *_Nullable *_Nullable)front;
- (void)updateDataForKeys:(NSArray *)keys value:(id)value;

- (NSString *)addMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeys:(NSArray *)keys;
//- (void)removeMLNUIObserver:(NSObject<MLNUIKVOObserverProtol> *)observer forKeys:(NSArray *)keys;

//缓存listView及对应的tag
- (void)setListView:(UIView *)view tag:(NSString *)tag;
- (UIView *)listViewForTag:(NSString *)tag;

@property (nonatomic, strong)void(^errorLog)(NSString *);
@end



NS_ASSUME_NONNULL_END
