//
//  MLNLink.h
//  MLN
//
//  Created by MOMO on 2020/4/30.
//

#import <Foundation/Foundation.h>
#import "MLNStaticExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNLink : NSObject<MLNStaticExportProtocol>

+ (void)registerName:(NSString *)name linkClass:(Class)cls;
+ (void)registerName:(NSString *)name linkClassName:(NSString *)clsName;

@end

NS_ASSUME_NONNULL_END
