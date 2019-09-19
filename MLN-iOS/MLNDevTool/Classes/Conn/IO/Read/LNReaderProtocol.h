//
//  MLNReaderProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#ifndef LNReaderProtocol_h
#define LNReaderProtocol_h
#import <UIKit/UIKit.h>

@protocol LNReaderProtocol <NSObject>

- (void)read:(NSData *)data;
- (void)onMessage:(void(^)(id message))callback;

@end

#endif /* LNReaderProtocol_h */
