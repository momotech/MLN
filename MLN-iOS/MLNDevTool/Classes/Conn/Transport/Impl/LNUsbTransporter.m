//
//  MLNUsbTransporter.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import "LNUsbTransporter.h"
#import "MLN_GCDAsyncSocket.h"

@interface LNUsbTransporter () <MLN_GCDAsyncSocketDelegate>

@property (nonatomic, assign) int port;
@property (nonatomic, strong) MLN_GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) MLN_GCDAsyncSocket *clientSocket;
@property (nonatomic, weak) id<LNTransporterListener> listener;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end
@implementation LNUsbTransporter

- (instancetype)initWithPort:(int)port
{
    if (self = [super init]) {
        _port = port;
    }
    return self;
}

- (void)sendData:(NSData *)data {
    [self.clientSocket writeData:data withTimeout:-1 tag:0x04];
}

- (BOOL)startWithListener:(id<LNTransporterListener>)listener {
    self.listener = listener;
    BOOL ret = YES;
#define TIME_OUT 20
    if (!_serverSocket) {
        _serverSocket = [[MLN_GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        NSError *error = nil;
        NSLog(@">>>>>> startWithListener %@", _serverSocket);
        ret = [_serverSocket acceptOnInterface:kMLNLocalHost port:self.port error:&error];
        if (!ret) {
            _serverSocket = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listener disconnectedWithError:error];
            });
            return NO;
        }
    }
    return ret;
}

- (void)stop {
    NSLog(@"_serverSocket stop");
    self.lock = dispatch_semaphore_create(0);
    [self.clientSocket disconnect];
    [_serverSocket disconnect];
    dispatch_semaphore_wait(self.lock , DISPATCH_TIME_FOREVER);
}

- (NSString *)ip {
    return kMLNUSBIP;
}

- (int)port {
    return _port;
}

- (BOOL)isReachable {
    if (self.clientSocket) {
        return self.clientSocket.isConnected;
    }
    return NO;
}

- (void)socket:(MLN_GCDAsyncSocket *)sock didAcceptNewSocket:(MLN_GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    [self.clientSocket disconnect];
    self.clientSocket = newSocket;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listener onConnected];
        [self.listener requestForCertification];
        [sock enableBackgroundingOnSocket];
        [newSocket enableBackgroundingOnSocket];
    });
    //一直等待客户端数据,一直收到\r\n才返回.
    [newSocket readDataWithTimeout:-1 tag:0x04];
}

- (void)socket:(MLN_GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.listener didReceiveData:data];
    [sock readDataWithTimeout:-1 tag:0x04];
}

- (void)socketDidDisconnect:(MLN_GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    if (sock == self.clientSocket) {
        _clientSocket = nil;
    } else if (sock == _serverSocket) {
        NSLog(@"<<<<<<<< socketDidDisconnect %@", _serverSocket);
        _serverSocket = nil;
        if (self.lock) {
            dispatch_semaphore_signal(self.lock);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self->_serverSocket) {
                NSLog(@"++++++ disconnectedWithError %@", err);
                [self.listener disconnectedWithError:err];
            }
        });
    }
}

@end
