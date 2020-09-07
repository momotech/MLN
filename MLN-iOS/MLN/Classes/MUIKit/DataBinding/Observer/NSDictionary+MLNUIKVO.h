//
//  NSDictionary+MLNUIKVO.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ArgoObservableMap;
@interface NSDictionary (MLNUIKVO)
- (NSMutableDictionary *)mlnui_mutalbeCopy;
- (NSDictionary *)mlnui_convertToLuaTableAvailable;
- (NSMutableDictionary *)mlnui_convertToMDic;

- (ArgoObservableMap *)argo_mutableCopy;

@end

@interface NSMutableDictionary (MLNUIKVO)
- (NSDictionary *)mlnui_copy;
- (void)mlnui_setValue:(id)value forKeyPath:(NSString *)keyPath createIntermediateObject:(BOOL)createIntermediateObject;
@end

NS_ASSUME_NONNULL_END
