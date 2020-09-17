//
//  ArgoListenerWrapper.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoListenerWrapper : NSObject {
    @private
    BOOL _cancel;
}
@property (nonatomic, assign) NSInteger obID;
@property (nonatomic, unsafe_unretained, nullable) id<ArgoListenerProtocol> observedObject; // for keyPath
@property (nonatomic, copy) NSString *keyPath; //userData.data.info.name
@property (nonatomic, strong, nullable, readonly) ArgoBlockChange block;

@property (nonatomic, copy) NSString *key; // info
//@property (nonatomic, copy) NSString *prefix;//userData.data (key的前缀）

//NSString *const kArgoListenerArrayPlaceHolder = @"ARGO_PH";
//kArgoListenerArrayPlaceHolder 表示监听的是数组变化(insert/replace/remove)
//kArgoListenerArrayPlaceHolder_SUPER_IS_2D 表示监听的是数组变化(insert/replace/remove),且数组位于二维数组内.
@property (nonatomic, copy) NSString *arrayKeyPath;

//监听多个keys
//@property (nonatomic, strong) NSSet *keys;

@property (nonatomic, strong) ArgoListenerFilter filter;
@property (nonatomic, assign) BOOL triggerWhenAdd;

//- (void)cancel;
- (BOOL)isCanceld;

+ (instancetype)wrapperWithID:(NSInteger)obID block:(ArgoBlockChange)block observedObject:(id<ArgoListenerProtocol>)observed keyPath:(NSString *)keyPath key:(NSString *)key filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd;

- (void)callWithChange:(NSDictionary *)change;

@end

NS_ASSUME_NONNULL_END
