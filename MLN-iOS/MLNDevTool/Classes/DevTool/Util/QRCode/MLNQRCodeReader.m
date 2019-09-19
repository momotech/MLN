//
//  MLNQRCode.m
//  Pods
//
//  Created by MoMo on 2019/9/6.
//

#import "MLNQRCodeReader.h"
#import <AVFoundation/AVFoundation.h>

@interface MLNQRCodeReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) dispatch_queue_t myQueue;
@property (nonatomic, strong) MLNQRCodeReaderCallback callback;
@property (nonatomic, weak) UIView *view;

@end
@implementation MLNQRCodeReader

static MLNQRCodeReader *_shareReader = nil;
+ (instancetype)shareReader
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareReader = [[MLNQRCodeReader alloc] init];
    });
    return _shareReader;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myQueue = dispatch_queue_create("com.mlndebugtool.qrcode", NULL);
    }
    return self;
}

- (void)startWithView:(UIView *)view callback:(MLNQRCodeReaderCallback)callback
{
    if (![self checkAuthorization]) {
        return;
    }
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
    self.view = view;
    self.callback = callback;
    [self setupIfNeed];
    self.previewLayer.frame = view.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.session startRunning];
    
}

- (void)stop
{
    self.view = nil;
    [self.session stopRunning];
    [self.previewLayer removeFromSuperlayer];
}

- (void)setupIfNeed
{
    if (self.session) {
        return;
    }
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (self.defaultDevice) {
        self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.defaultDevice error:nil];
        self.metadataOutput     = [[AVCaptureMetadataOutput alloc] init];
        self.session            = [[AVCaptureSession alloc] init];
        self.previewLayer       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.defaultDevice error:nil];
    }
    [self.session addOutput:self.metadataOutput];
    if (self.defaultDeviceInput) {
        [self.session addInput:self.defaultDeviceInput];
    }
    
    [self.metadataOutput setMetadataObjectsDelegate:self queue:self.myQueue];
    [self.metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (BOOL)checkAuthorization
{
    NSError *error = nil;
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        error = [NSError errorWithDomain:@"com.mlndebugtool.qrcode" code:-1 userInfo:@{@"errmsg":@"没有相机权限，請在iPhone的“設定”-“隱私”-“相機”功能中，找到“日照新出行”開啟相機訪問許可權"}];
        [self handleMsg:nil error:error];
        return NO;
    }
    return YES;
}

- (void)handleMsg:(NSString *)msg error:(NSError *)error
{
    if (self.callback) {
        self.callback(msg, error);
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray<AVMetadataMachineReadableCodeObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count == 0) {
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.session stopRunning];
        NSString *result = [metadataObjects.firstObject stringValue];
        //信息处理
        [self handleMsg:result error:nil];
    });
}

@end
