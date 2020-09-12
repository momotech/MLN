//
//  ArgoObserverHelper.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObserverHelper : NSObject

+ (BOOL)isNumber:(NSString *)str;
+ (NSInteger)lastNumberIndexOf:(NSArray <NSString *> *)keys;
+ (NSString *)stringBefor:(NSInteger)index withKeys:(NSArray <NSString *> *)keys;
+ (BOOL)arrayIs2D:(NSArray *)array;
+ (BOOL)hasNumberInKeys:(NSArray *)keys fromIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
