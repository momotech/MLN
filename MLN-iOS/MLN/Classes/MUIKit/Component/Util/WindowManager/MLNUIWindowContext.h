//
//  MLNUIWindowContext.h
//
//
//  Created by MoMo on 2019/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIWindowContext : NSObject

@property (nonatomic, strong, readonly) NSArray *allObject;

+ (instancetype)sharedContext;

- (void)pushKeyWindow:(UIWindow *)keyWindow;

- (UIWindow *)popKeyWindow;

- (void)removeWithWindow:(UIWindow *)keyWindow;

- (UIWindow *)topWindow;

@end

NS_ASSUME_NONNULL_END
