//
//  MLNEncoderProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#ifndef LNEncoderProtocol_h
#define LNEncoderProtocol_h
#import <Foundation/Foundation.h>

@protocol LNEncoderProtocol <NSObject>

- (NSData *)encode:(id)msg;

@end

#endif /* LNEncoderProtocol_h */
