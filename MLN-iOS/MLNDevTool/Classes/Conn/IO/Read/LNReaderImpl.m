//
//  MLNReaderImpl.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNReaderImpl.h"
#import "LNDecoderFactory.h"
#import "NSData+LuaNative.h"
#import "PBCommandBuilder.h"

typedef enum : Byte {
    LNPackageType_Msg = 0x01,
    LNPackageType_Ping = 0x02,
    LNPackageType_Pong = 0x03,
} LNPackageType;


@interface LNReaderImpl ()

@property (nonatomic, strong) id<LNDecoderProtocol> decoder;
@property (nonatomic, strong) NSMutableData *rawData;
@property (nonatomic, copy) void (^callback)(id message);
@property (nonatomic, strong) dispatch_queue_t readerQueue;

@end
@implementation LNReaderImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        _decoder = [LNDecoderFactory getDecoder];
    }
    return self;
}

- (void)read:(NSData *)data
{
    if (self.rawData) {
        [self.rawData appendData:data];
    } else {
        self.rawData = [NSMutableData dataWithData:data];
    }
    self.rawData = [self preccess:self.rawData].mutableCopy;
}

- (NSData *)preccess:(NSData *)data
{
    NSMutableData *buffer = data.mutableCopy;
    LNPackageType pkgType = [self getPackageType:buffer];
    int headerLength = [self getHeaderLengthPkgType:pkgType];
    int bodyType = [self getBodyType:buffer withPackageType:pkgType];
    int bodyLength = [self getBodyLength:buffer pkgType:pkgType];
    int completedLength = headerLength + bodyLength + 1;
    if (buffer.length > completedLength) {
        // 多余一个包
        unsigned long remainLength = buffer.length - completedLength;
        NSMutableData *remainData = [NSMutableData dataWithData:[buffer subdataWithRange:NSMakeRange(completedLength, remainLength)]];
        NSData *completedData = [buffer subdataWithRange:NSMakeRange(headerLength, bodyLength)];
        id msg = [self.decoder decode:completedData type:bodyType];
        if (self.callback) {
            self.callback(msg);
        }
        if (remainData.length < headerLength) {
            return data;
        }
        return [self preccess:remainData];
    } else if(buffer.length == completedLength) {
        // 一个完整的包
        NSData *completedData = [buffer subdataWithRange:NSMakeRange(headerLength, bodyLength)];
        id msg = [self.decoder decode:completedData type:bodyType];
        if (self.callback) {
            self.callback(msg);
        }
        return nil;
    }
    
    // 不足一个包
    return data;
}

- (void)onMessage:(void (^)(id))callback
{
    self.callback = callback;
}

- (LNPackageType)getPackageType:(NSData *)rawData
{
    return [rawData getByte:0];
}

- (int)getHeaderLengthPkgType:(LNPackageType)pkgType
{
    if (pkgType == LNPackageType_Msg) {
        return 9;//1 + 4 +4
    }
    return 7; // 1 + 4 + 2
}

- (int)getBodyType:(NSData *)rawData withPackageType:(LNPackageType)pkgType
{
    switch (pkgType) {
        case LNPackageType_Msg:
            return [rawData getInt32:1];
        case LNPackageType_Ping:
            return pbbasecommand_InstructionType_Ping;
        case LNPackageType_Pong:
            return pbbasecommand_InstructionType_Pong;
        default:
            return -1;
    }
}

- (int)getBodyLength:(NSData *)rawData pkgType:(LNPackageType)pkgType
{
    if (pkgType == LNPackageType_Msg) {
        return [rawData getInt32:5];
    }
    return 0;
}

@end
