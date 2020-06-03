//
//  MLNUIHttpDefaultHandler.m
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIHttpDefaultHandler.h"

//TODO: - 实现基本的网络请求
@implementation MLNUIHttpDefaultHandler

- (void)http:(MLNUIHttp *)http download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(void (^)(float, float))progressHandler completionHandler:(void (^)(BOOL, NSDictionary *, id, NSDictionary *))completionHandler {
    
}

- (void)http:(MLNUIHttp *)http get:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void (^)(BOOL, NSDictionary *, NSDictionary *))completionHandler {
    
}

- (void)http:(MLNUIHttp *)http post:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void (^)(BOOL, NSDictionary *, NSDictionary *))completionHandler {
    
}

- (void)http:(MLNUIHttp *)http upload:(NSString *)urlString params:(NSDictionary *)params filePaths:(NSArray *)filePaths fileNames:(NSArray *)fileNames completionHandler:(void (^)(BOOL, NSDictionary *, NSDictionary *))completionHandler {
    
}

@end
