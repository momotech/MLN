//
//  MLNUSBWriterImpl.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/12.
//

#import "LNUSBWriterImpl.h"
#import "PBCommandBuilder.h"
#import "LNEncoderFactory.h"

@interface LNUSBWriterImpl ()

@property (nonatomic, strong) id<LNEncoderProtocol> encoder;
@property (nonatomic, copy) void (^outPutHandler)(NSData *data);

@end

@implementation LNUSBWriterImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        _encoder = [LNEncoderFactory getEncoder];
    }
    return self;
}

- (void)writeData:(id)data {
    NSData *encodedData = [self.encoder encode:data];
    if (self.outPutHandler) {
        self.outPutHandler(encodedData);
    }
}

- (void)writeDevice:(id)data {
    pbdevicecommand *deviceCmd = [PBCommandBuilder buildDeviceCmdNotUUID];
    NSData *encodedData = [self.encoder encode:deviceCmd];
    if (self.outPutHandler) {
        self.outPutHandler(encodedData);
    }
}

- (void)writeError:(id)data entryFilePath:(NSString *)entryFilePath {
    pberrorcommand *cmd = [PBCommandBuilder buildErrorCmdNotUUID:data entryFilePath:entryFilePath];
    NSData *encodedData = [self.encoder encode:cmd];
    if (self.outPutHandler) {
        self.outPutHandler(encodedData);
    }
}

- (void)writeLog:(id)data entryFilePath:(NSString *)entryFilePath {
    pblogcommand *cmd = [PBCommandBuilder buildLogCmdNotUUID:data entryFilePath:entryFilePath];
    NSData *encodedData = [self.encoder encode:cmd];
    if (self.outPutHandler) {
        self.outPutHandler(encodedData);
    }
}

- (void)writePing {
    pbpingcommand *cmd = [PBCommandBuilder buildPingCmd];
    NSData *encodedData = [self.encoder encode:cmd];
    if (self.outPutHandler) {
        self.outPutHandler(encodedData);
    }
}

- (void)onOutPut:(void (^)(NSData *))handler {
    self.outPutHandler = handler;
}

@end
