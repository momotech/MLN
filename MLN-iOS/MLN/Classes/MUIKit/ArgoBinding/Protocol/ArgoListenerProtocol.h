//
//  ArgoListenerProtocol.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#ifndef ArgoListenerProtocol_h
#define ArgoListenerProtocol_h
#import "ArgoKitDefinitions.h"
#import "ArgoObservableObject.h"

//typedef NS_ENUM(NSUInteger, ArgoWatchContext) {
//    ArgoWatchContext_Lua,
//    ArgoWatchContext_Native
//};

@class ArgoListenerWrapper, ArgoListenerToken, MLNUILuaTable, MLNUILuaCore;
@protocol ArgoListenerProtocol;

//typedef void(^ArgoBlockChange)  (id <ArgoListenerProtocol> object, NSDictionary<NSKeyValueChangeKey,id> * change);
//typedef void(^ArgoBlockChange)  (NSKeyValueChange type, id newValue, NSIndexSet *indexSet, NSDictionary *info);
typedef void(^ArgoBlockChange)  (NSString *keyPath, id<ArgoListenerProtocol>object, NSDictionary *change);
typedef BOOL(^ArgoListenerFilter)(ArgoWatchContext context, NSDictionary *change);

extern ArgoListenerFilter kArgoWatchKeyListenerFilter;

@protocol ArgoListenerToken
//- (void)removeObserver;
- (void)removeListener;
@property (nonatomic, assign) NSInteger tokenID;
@end

@protocol ArgoListenerLuaTableProtocol <NSObject>

- (void)addLuaTabe:(MLNUILuaTable *)table;
- (MLNUILuaTable *)getLuaTable:(id<NSCopying>)key;

@end

@protocol ArgoListenerCategoryProtocol <NSObject>
//- (id <ArgoListenerToken>)addArgoListenerWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath;
- (id <ArgoListenerToken>)addArgoListenerWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd;
// for bind_cell
- (id<ArgoListenerToken>)addArgoListenerWithChangeBlockForAllKeys:(ArgoBlockChange)block filter:(ArgoListenerFilter)filter keyPaths:(NSArray *)keyPaths triggerWhenAdd:(BOOL)triggerWhenAdd;

- (void)removeArgoListenerWithToken:(id <ArgoListenerToken>)token;

- (void)addArgoListenerWrapper:(ArgoListenerWrapper *)wrapper;
- (void)removeArgoListenerWrapper:(ArgoListenerWrapper *)wrapper;
- (void)notifyArgoListenerKey:(NSString *)key Change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change;

- (id)argoGetForKeyPath:(NSString *)keyPath;
- (void)argoPutValue:(NSObject *)value forKeyPath:(NSString *)keyPath;

@end

@protocol ArgoListenerForLuaArray <NSObject>

- (void)lua_addObject:(NSObject *)object;
- (void)lua_insertObject:(NSObject *)object atIndex:(int)index;

- (void)lua_removeObjectAtIndex:(int)index;
- (void)lua_removeLastObject;
@end

@protocol  ArgoListenerProtocol <ArgoListenerLuaTableProtocol, ArgoListenerCategoryProtocol, ArgoObservableObject>
//- (ArgoListenerWrapper *)addObserverWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath;
- (NSObject *)lua_get:(NSString *)key;
- (void)lua_putValue:(NSObject *)value forKey:(NSString *)key;
//
- (void)lua_rawPutValue:(NSObject *)value forKey:(NSString *)key;

@property (nonatomic, strong, readonly) NSMutableDictionary <id<NSCopying>, ArgoListenerWrapper *> *argoListeners;
@property (nonatomic, strong, readonly) NSMutableDictionary *argoChangedKeysMap;

@end 
#endif /* ArgoListenerProtocol_h */
