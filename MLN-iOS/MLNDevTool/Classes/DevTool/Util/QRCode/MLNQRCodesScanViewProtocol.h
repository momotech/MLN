//
//  MLNQRCodesScanViewProtocol.h
//  MLN
//
//  Created by MoMo on 2019/9/10.
//

#ifndef MLNQRCodesScanViewProtocol_h
#define MLNQRCodesScanViewProtocol_h
#import <Foundation/Foundation.h>

@protocol MLNQRCodesScanViewProtocol <NSObject>

- (void)start;
- (void)stop;
- (void)setCancelCallback:(void(^)(void))callback;
- (void)setHistoryCallback:(void(^)(void))callback;

@end

#endif /* MLNQRCodesScanViewProtocol_h */
