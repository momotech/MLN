//
//  UIDevice+HotReload.h
//  MLN
//
//  Created by MoMo on 2019/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (HotReload)

- (NSString*)getSerialNumber;
- (void)updateSerialNumber:(NSString *)serialNumber;
- (NSString*)getUUID;
- (NSString *)getModel;
- (NSString *)getIPv4Address;
- (NSString *)getIPv6Address;

@end

NS_ASSUME_NONNULL_END
