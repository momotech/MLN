//
//  ArgoObservableObject.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/4.
//

#ifndef ArgoObservableObject_h
#define ArgoObservableObject_h

@protocol ArgoObservableObject

- (void)native_putValue:(NSObject *)value forKey:(NSString *)key;
// 只是简单赋值，不会触发数据监听
- (void)native_rawPutValue:(NSObject *)value forKey:(NSString *)key;
@end

#endif /* ArgoObservableObject_h */
