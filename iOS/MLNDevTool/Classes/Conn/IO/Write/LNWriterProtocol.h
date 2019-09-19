//
//  MLNWriterProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#ifndef LNWriterProtocol_h
#define LNWriterProtocol_h
#import <UIKit/UIKit.h>

@protocol LNWriterProtocol <NSObject>

- (void)writeData:(id)data;
- (void)writeLog:(id)data entryFilePath:(NSString *)entryFilePath;
- (void)writeError:(id)data entryFilePath:(NSString *)entryFilePath;
- (void)writeDevice:(id)data;
- (void)writePing;

- (void)onOutPut:(void(^)(NSData *data))handler;

@end

#endif /* LNWriterProtocol_h */
