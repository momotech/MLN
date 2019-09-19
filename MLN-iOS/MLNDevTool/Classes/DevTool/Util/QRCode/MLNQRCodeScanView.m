//
//  MLNQRCodeScanView.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/10.
//

#import "MLNQRCodeScanView.h"
#import "MLNUtilBundle.h"

@interface MLNQRCodeScanView ()

@property (weak, nonatomic) IBOutlet UIImageView *scanZoneView;
@property (weak, nonatomic) IBOutlet UIImageView *scanLineView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanLineTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanZoneHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanLineHeight;
@property (weak, nonatomic) IBOutlet UIImageView *historyImage;
@property (nonatomic, strong) UITapGestureRecognizer *historyTap;
@property (nonatomic, copy) void (^cancelCallback)(void);
@property (nonatomic, copy) void (^historyCallback)(void);

@end

@implementation MLNQRCodeScanView

+ (instancetype)QRCodeScanViewWithFrame:(CGRect)frame {
    MLNQRCodeScanView *view = [[[MLNUtilBundle utilBundle] loadNibNamed:@"MLNQRCodeScanView" owner:self options:NULL] firstObject];
    view.frame = frame;
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSString *path = [[MLNUtilBundle utilBundle] pngPathWithName:@"scan_corner"];
    self.scanZoneView.image = [UIImage imageNamed:path];
    NSString *linePath = [[MLNUtilBundle utilBundle] pngPathWithName:@"scan_line"];
    self.scanLineView.image = [UIImage imageNamed:linePath];
    NSString *historyPath = [[MLNUtilBundle utilBundle] pngPathWithName:@"history"];
    self.historyImage.image = [UIImage imageNamed:historyPath];
    UITapGestureRecognizer *historyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyTapAction)];
    [self.historyImage addGestureRecognizer:historyTap];
    self.historyTap = historyTap;
    self.cancelBtn.layer.cornerRadius = 5.f;
    self.cancelBtn.clipsToBounds = YES;
    [self.cancelBtn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)start {
    if (self.scanLineTop.constant == self.scanZoneHeight.constant - self.scanLineHeight.constant) {
        self.scanLineTop.constant = 0.f;
        [self layoutIfNeeded];
        
    }
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        self.scanLineTop.constant = self.scanZoneHeight.constant - self.scanLineHeight.constant;
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)stop {
    [self.scanLineView.layer removeAllAnimations];
}

- (void)setCancelCallback:(void (^)(void))callback {
    _cancelCallback = callback;
}

- (void)onClick
{
    if (self.cancelCallback) {
        self.cancelCallback();
    }
}

- (void)historyTapAction
{
    if (self.historyCallback) {
        self.historyCallback();
    }
}

@end
