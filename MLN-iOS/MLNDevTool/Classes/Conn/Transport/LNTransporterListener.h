//
//  MLNTransporterListener.h
//  Pods
//
//  Created by MoMo on 2019/7/11.
//

#ifndef LNTransporterListener_h
#define LNTransporterListener_h
#import <UIKit/UIKit.h>

@protocol LNTransporterListener <NSObject>

- (void)onConnected;
- (void)requestForCertification;
- (void)didReceiveData:(NSData *_Nullable)data;
- (void)disconnectedWithError:(nullable NSError *)error;

@end

#endif /* LNTransporterListener_h */
