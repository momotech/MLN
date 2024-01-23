//
//  MLNDecoderProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#ifndef LNDecoderProtocol_h
#define LNDecoderProtocol_h
#import <Foundation/Foundation.h>

@protocol LNDecoderProtocol <NSObject>

- (id)decode:(NSData *)data type:(int)type;

@end

#endif /* LNDecoderProtocol_h */
