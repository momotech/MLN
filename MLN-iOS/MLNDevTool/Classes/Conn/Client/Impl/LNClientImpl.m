//
//  MLNClientImpl.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNClientImpl.h"
#import "LNWriterFactory.h"
#import "LNReaderFactory.h"
#import "PBCommandBuilder.h"

@interface LNClientImpl ()

@property (nonatomic, strong) id<LNReaderProtocol> reader;
@property (nonatomic, strong) id<LNWriterProtocol> writer;
@property (nonatomic, weak) id<LNClientListener> listener;
@property (nonatomic, strong) id<LNTransporterProtocol>transporter;
@property (nonatomic, copy) void (^outPutHandler)(NSData *data);
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation LNClientImpl

- (instancetype)initWithTransporter:(id<LNTransporterProtocol>)transporter listener:(id<LNClientListener>)listener
{
    self = [super init];
    if (self) {
        _transporter = transporter;
        _listener = listener;
        _reader = [LNReaderFactory getReader];
        _writer = [LNWriterFactory getWriter];
        __weak typeof(self) wself = self;
        [_writer onOutPut:^(NSData *data) {
            __strong typeof(wself) sself = self;
            [sself->_transporter sendData:data];
            if (sself->_outPutHandler) {
                sself->_outPutHandler(data);
            }
        }];
        _lock = dispatch_semaphore_create(0);
    }
    return self;
}

- (BOOL)start {
    if (!_isRunning) {
        _isRunning = [_transporter startWithListener:self];
        return _isRunning;
    }
    return YES;
}

- (void)stop {
    if (_isRunning) {
        [_transporter stop];
        _isRunning = NO;
    }
}

- (BOOL)isRunning {
    return _isRunning;
}

- (NSString *)ip {
    return self.transporter.ip;
}

- (BOOL)isReachable {
    return self.transporter.isReachable;
}

- (void)asyncCheckReachable:(void (^)(BOOL))callabck
{
    if (!callabck) {
        return;
    }
    if (self.transporter.isReachable) {
        callabck(NO);
        return;
    }
    
    // ping
    [self writePing];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC));
        long ret = dispatch_semaphore_wait(self.lock, timeout);
        dispatch_async(dispatch_get_main_queue(), ^{
            callabck(ret == 0);
        });
    });
}

- (int)port {
    return self.transporter.port;
}

- (void)didReceiveData:(NSData *)data {
    [self read:data];
}

- (void)disconnectedWithError:(nullable NSError *)error {
    [self.listener client:self disconnectedWithError:error];
}

- (void)onConnected {
    [self.listener clientOnConnected:self];
}

- (void)requestForCertification {
    [self.writer writeDevice:nil];
    [self.listener clientRequestForCertification:self];
}

- (void)writeData:(id)data {
    [self.writer writeData:data];
}

- (void)writeDevice:(id)data {
    [self.writer writeDevice:data];
}

- (void)writeError:(id)data entryFilePath:(NSString *)entryFilePath {
    [self.writer writeError:data entryFilePath:entryFilePath];
}

- (void)writePing {
    [self.writer writePing];
}

- (void)writeLog:(id)data entryFilePath:(NSString *)entryFilePath {
    [self.writer writeLog:data entryFilePath:entryFilePath];
}

- (void)read:(NSData *)data {
    [self.reader read:data];
}

- (void)onMessage:(void (^)(id))callback {
    [self.reader onMessage:^(id message) {
        if ([message isKindOfClass:[pbpongcommand class]]) {
            dispatch_semaphore_signal(self.lock);
        } else {
            if (callback) {
                callback(message);
            }
        }
    }];
}

- (void)onOutPut:(void (^)(NSData *))handler {
    self.outPutHandler = handler;
}

@end
