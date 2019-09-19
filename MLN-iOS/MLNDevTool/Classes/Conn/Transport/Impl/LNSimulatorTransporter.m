//
//  MLNSimulatorTransporter.m
//  MLNDebugger
//
//  Created by MoMo on 2019/8/16.
//

#import "LNSimulatorTransporter.h"
#import "MLN_GCDAsyncSocket.h"

@interface LNSimulatorTransporter () <MLN_GCDAsyncSocketDelegate>

@property (nonatomic, assign) int port;
@property (nonatomic, strong) MLN_GCDAsyncSocket *socket;
@property (nonatomic, weak) id<LNTransporterListener> listener;

@end

@implementation LNSimulatorTransporter

- (instancetype)initWithPort:(int)port
{
    if (self = [super init]) {
        _port = port;
    }
    return self;
}

- (BOOL)startWithListener:(id<LNTransporterListener>)listener {
    self.listener = listener;
    BOOL ret = YES;
#define TIME_OUT 20
    if (!_socket) {
        _socket = [[MLN_GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        NSError *error = nil;
        ret = [_socket connectToHost:kMLNLocalHostIP onPort:self.port withTimeout:TIME_OUT error:&error];
        if (!ret) {
            _socket = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listener disconnectedWithError:error];
            });
        }
    }
    return ret;
}

- (void)stop
{
    [_socket disconnect];
    _socket = nil;
}

- (void)sendData:(NSData *)data
{
    if ([_socket isConnected]) {
        [_socket writeData:data withTimeout:-1 tag:0x04];
    }
}

- (NSString *)ip {
    return kMLNSimulatorIP;
}

- (int)port {
    return _port;
}

- (BOOL)isReachable {
    return self.socket.isConnected;
}

-(void)socket:(MLN_GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listener onConnected];
        [self.listener requestForCertification];
        [sock enableBackgroundingOnSocket];
    });
    [_socket readDataWithTimeout:-1 tag:0x04];
}

- (void)socket:(MLN_GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.listener didReceiveData:data];
    [_socket readDataWithTimeout:-1 tag:0x04];
}

- (void)socketDidDisconnect:(MLN_GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listener disconnectedWithError:err];
    });
}

@end
