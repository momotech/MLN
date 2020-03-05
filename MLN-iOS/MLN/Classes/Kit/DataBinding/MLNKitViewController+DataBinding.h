//
//  MLNKitViewController+DataBinding.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNKitViewController.h"
#import "MLNKVOObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNKitViewController (DataBinding)

/**
通过id获取视图

@param identifier 视图对应的id
*/
- (UIView *)findViewById:(NSString *)identifier;

/**
 模型数据绑定
 
 @param data 要绑定的数据
 @param key 访问数据的Key
 */
- (void)bindData:(NSObject *)data key:(NSString *)key;

/**
 更新绑定的模型数据
 
 @param keyPath 访问数据的Key
 @param value 要更新的数据
 */
- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value;

/**
 获取绑定的模型数据
 
 @param keyPath 访问数据的Key
 @return 对应的数据
 */
- (id __nullable)dataForKeyPath:(NSString *)keyPath;

/**
 监听数据变化
 
 @param observer 监听者
 @param keyPath 访问数据的Key
 */
- (void)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;

/**
移除监听

@param observer 监听者
@param keyPath 访问数据的Key
*/
- (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath;

@end

@class MLNDataBinding;
@interface MLNKitViewController () {
    MLNDataBinding *_dataBinding;
}
@property (nonatomic, strong, readonly) MLNDataBinding *dataBinding;
@end

NS_ASSUME_NONNULL_END
