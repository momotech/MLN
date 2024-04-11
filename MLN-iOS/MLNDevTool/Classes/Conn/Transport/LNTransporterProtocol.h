//
//  MLNTransporterProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#ifndef LNTransporterProtocol_h
#define LNTransporterProtocol_h
#import <UIKit/UIKit.h>
#import "LNTransporterListener.h"

#define kMLNLocalHost @"localhost"
#define kMLNLocalHostIP @"127.0.0.1"
#define kMLNUSBIP @"127.0.0.1:usb"
#define kMLNSimulatorIP @"127.0.0.1:Simulator"

@protocol LNTransporterProtocol <NSObject>

- (BOOL)startWithListener:(id<LNTransporterListener>)listener;
- (void)stop;
- (void)sendData:(NSData *)data;

- (BOOL)isReachable;
- (NSString *)ip;
- (int)port;

@end

#endif /* LNTransporterProtocol_h */
