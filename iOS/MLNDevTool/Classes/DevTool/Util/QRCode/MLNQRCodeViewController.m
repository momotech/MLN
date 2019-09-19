//
//  MLNQRCodeViewController.m
//  Pods
//
//  Created by MoMo on 2019/9/6.
//

#import "MLNQRCodeViewController.h"
#import "MLNQRCodeReader.h"
#import "MLNQRCodeScanView.h"

@interface MLNQRCodeViewController ()

@property (nonatomic, strong) UIView<MLNQRCodesScanViewProtocol> *scanView;
@property (nonatomic, strong) UILabel *closeLabel;

@end
@implementation MLNQRCodeViewController

- (void)setupScanView:(UIView<MLNQRCodesScanViewProtocol> *)scanView
{
    self.scanView = scanView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.scanView) {
        self.scanView = [MLNQRCodeScanView QRCodeScanViewWithFrame:self.view.bounds];
    }
    __weak typeof(self) wself = self;
    [self.scanView setCancelCallback:^{
        __strong typeof(wself) sself = wself;
        if ([sself.delegate respondsToSelector:@selector(onCancelQRCodeViewController:)]) {
            [sself.delegate onCancelQRCodeViewController:sself];
        }
    }];
    [self.scanView setHistoryCallback:^{
        __strong typeof(wself) sself = wself;
        if ([sself.delegate respondsToSelector:@selector(openHistoryQRCodeViewController:)]) {
            [sself.delegate openHistoryQRCodeViewController:sself];
        }
    }];
    [self.view addSubview:self.scanView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __weak typeof(self) wself = self;
    [[MLNQRCodeReader shareReader] startWithView:self.view callback:^(NSString * _Nullable result, NSError * _Nullable error) {
        __strong typeof(wself) sself = wself;
        [sself.scanView stop];
        if (error) {
            if ([sself.delegate respondsToSelector:@selector(QRCodeViewController:error:)]) {
                [sself.delegate QRCodeViewController:sself error:error];
            }
        } else {
            if ([sself.delegate respondsToSelector:@selector(QRCodeViewController:readData:)]) {
                [sself.delegate QRCodeViewController:sself readData:result];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scanView start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[MLNQRCodeReader shareReader] stop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.scanView stop];
}

- (UIView *)closeLabel
{
    if (!_closeLabel) {
        _closeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _closeLabel.backgroundColor = [UIColor redColor];
    }
    return _closeLabel;
}

@end
