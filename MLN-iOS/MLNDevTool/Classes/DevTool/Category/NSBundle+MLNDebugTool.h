//
//  NSBundle+HotReload.h
//  MLN
//
//  Created by MoMo on 2019/9/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (MLNDebugTool)

+ (instancetype)bundleWithClass:(Class)clazz name:(NSString *)name;

- (NSString *)pngPathWithName:(NSString *)name;
- (NSString *)luaPathWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
