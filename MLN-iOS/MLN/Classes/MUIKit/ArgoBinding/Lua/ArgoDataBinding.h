//
//  ArgoDataBinding.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import "ArgoObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUIBlock, MLNUILuaTable;
@interface ArgoDataBinding : NSObject

- (void)bindData:(nullable NSObject<ArgoListenerProtocol> *)data;
- (void)bindData:(nullable NSObject<ArgoListenerProtocol> *)data forKey:(NSString *)key;

//- (id __nullable)dataForKeyPath:(NSString *)keyPath;
//- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value;

@property (nonatomic, strong)void(^errorLog)(NSString *log);
@end

// for Lua
@interface ArgoDataBinding ()

- (id __nullable)argo_get:(NSString *)keyPath;
- (void)argo_updateValue:(id)value forKeyPath:(NSString *)keyPath;
- (NSInteger)argo_watchKeyPath:(NSString *)keyPath withHandler:(MLNUIBlock *)handler filter:(MLNUIBlock *)filter;
- (NSInteger)argo_watchKey:(NSString *)key withHandler:(MLNUIBlock *)handler filter:(MLNUIBlock *)filter;
- (void)argo_unwatch:(NSInteger)tokenID;

- (NSInteger)argo_bindListView:(UIView *)listView forTag:(NSString *)tag;
- (UIView *)argo_listViewForTag:(NSString *)tag;

- (void)argo_bindCellWithController:(UIViewController *)viewController KeyPath:(NSString *)keyPath section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths;

- (MLNUILuaTable *)luaTableOf:(id<ArgoObserverProtocol>)object;

@end

NS_ASSUME_NONNULL_END
