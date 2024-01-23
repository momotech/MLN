//
//  MLNWidgetCacheManager.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/7.
//

#import <Foundation/Foundation.h>
@class MLNDependenceWidget;

NS_ASSUME_NONNULL_BEGIN

@interface MLNWidgetCacheManager : NSObject

+ (instancetype)shareManager;

-(void)updateWith:(NSString *) wid withPath:(NSString *) path;

-(void)removeWith:(NSString *) wid;

-(NSString *)queryWith:(NSString *) wid;

@end

NS_ASSUME_NONNULL_END
