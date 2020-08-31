//
//  ArgoObserableObject.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

static NSString *const kArgoListenerArrayPlaceHolder;

@class ArgoObserableObject;
typedef void(^ArgoDeallocCallback)(id receiver);
//typedef void(^ArgoKVOBlock)(id observedObject, id _Nullable oldValue, id _Nullable newValue);

//typedef void(^ArgoBlockChange)  (ArgoObserableObject *object, NSDictionary<NSKeyValueChangeKey,id> * change);


//@protocol ArgoListenerProtocol
//- (void)observeKeyPath:(NSString *)keyPath callback:(ArgoBlockChange)callback owner:()
//@end

@interface ArgoObserableObject : NSObject

//@property (nonatomic, copy, readonly) ArgoObserableObject *(^watch)(NSString *keyPath, ArgoKVOBlock block);

- (void)addObserverWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath;

//- (void)addDeallocCallback:(ArgoDeallocCallback)callback;
//- (void)notifySettingWithKey:(NSString *)key old:(nullable NSObject *)oldV new:(nullable NSObject *)newV;
- (void)notifyKey:(NSString *)key Change:(NSDictionary<NSKeyValueChangeKey,id> *)change;

- (NSObject *)get:(NSString *)key;
- (void)put:(NSString *)key value:(NSObject *)value;


//- (void)addObserverWrapper:(ArgoObserverWrapper *)wrapper;
//- (void)removeObserverWrapper:(ArgoObserverWrapper *)wrapper;

@end

NS_ASSUME_NONNULL_END
