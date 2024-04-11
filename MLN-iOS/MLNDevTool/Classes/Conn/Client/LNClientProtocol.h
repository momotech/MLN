//
//  MLNClientProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#ifndef LNClientProtocol_h
#define LNClientProtocol_h
#import <UIKit/UIKit.h>
#import "LNReaderProtocol.h"
#import "LNWriterProtocol.h"
#import "LNTransporterProtocol.h"
#import "LNClientListener.h"

@protocol LNClientProtocol <LNTransporterListener, LNWriterProtocol, LNReaderProtocol>

- (instancetype)initWithTransporter:(id<LNTransporterProtocol>)transporter listener:(id<LNClientListener>)listener;
- (BOOL)start;
- (void)stop;
- (BOOL)isRunning;

- (BOOL)isReachable;
- (void)asyncCheckReachable:(void(^)(BOOL isReachable))callabck;
- (NSString *)ip;
- (int)port;

@end

#endif /* LNClientProtocol_h */
