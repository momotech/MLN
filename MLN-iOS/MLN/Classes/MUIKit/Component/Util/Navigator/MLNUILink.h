//
//  MLNUILink.h
//  MLNUI
//
//  Created by MOMO on 2020/4/30.
//

#import <Foundation/Foundation.h>
#import "MLNUIStaticExportProtocol.h"
#import "MLNUILinkProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUILink : NSObject<MLNUIStaticExportProtocol>

+ (void)registerName:(NSString *)name linkClass:(Class)cls;
+ (void)registerName:(NSString *)name linkClassName:(NSString *)clsName;

@end

NS_ASSUME_NONNULL_END
