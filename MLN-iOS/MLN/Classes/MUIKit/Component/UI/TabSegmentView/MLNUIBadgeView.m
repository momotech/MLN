//
//  MLNUIBadgeView.m
//  MLNUI
//
//  Created by MoMo on 2019/1/16.
//

#import "MLNUIBadgeView.h"
#import "UIImage+MLNUI_IN_UTIL.h"

@interface MLNUIBadgeView()

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIControl *overlayView;

@property (nonatomic, strong) UIColor *shapeFillColor;
@property (nonatomic, copy) NSString *needUpdateBadgeValue;
@property (nonatomic, copy) NSString *needResumeBadgeValue;
@property (nonatomic, weak) UIView *originSuperView;
@property (nonatomic, weak) UIImageView *destoryView;

@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, assign) CGPoint originRightPoint;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) CGRect originContainerFrame;
@property (nonatomic, assign) CGPoint originCenter;

@property (nonatomic, assign) CGPoint fromPoint;
@property (nonatomic, assign) CGPoint toPoint;
@property (nonatomic, assign) CGPoint elasticBeginPoint;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat fromRadius;
@property (nonatomic, assign) CGFloat toRadius;
@property (nonatomic, assign) CGFloat viscosity;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat adsorbRadius;
@property (nonatomic, assign) CGFloat maxDistanceScaleCoefficient;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat maxDistance;

@end

@implementation MLNUIBadgeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.originPoint = frame.origin;
        _padding = 0;
        [self paramInitialize];
        _padding = 0;
         [self addSubview:self.backImageView];
        self.badgeLabel.frame = self.backImageView.frame;
        [self addSubview:self.badgeLabel];
        
    }
    return self;
}

- (instancetype)initWithOrigin:(CGPoint)origin
{
    CGRect frame = CGRectMake(origin.x, origin.y, 16.0, 16.0);
    return [self initWithFrame:frame];
}

- (UIImageView *)backImageView
{
    if (!_backImageView) {
        UIImage *image = [UIImage mln_in_imageWithColor:[UIColor colorWithRed:248/255.0 green:85/255.0 blue:67/255.0 alpha:1.0] finalSize:CGSizeMake(16, 16) cornerRadius:8];
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_padding, _padding, _originFrame.size.width, _originFrame.size.height)];
        
        [self setImage:image];
    }
    return _backImageView;
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.numberOfLines = 1;
        _badgeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _badgeLabel.backgroundColor = [UIColor clearColor];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_badgeLabel];
    }
    return _badgeLabel;
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    if (_badgeValue == badgeValue || [_badgeValue isEqualToString:badgeValue]) {
        
        if (badgeValue == nil) {
            self.hidden = YES;
        }
        return;
    }
    
    BOOL needFitSize = NO;
    if ((!_badgeValue && badgeValue) || (_badgeValue && !badgeValue) || (_badgeValue && badgeValue && _badgeValue.length != badgeValue.length)) {
        needFitSize = YES;
    }
    
    CGFloat fitVisibleWidth = self.originFrame.size.height + (badgeValue.length-1) * (CGRectGetHeight(self.originFrame) / 2.0f);
    if (badgeValue == nil || badgeValue.length == 0) {
        fitVisibleWidth = self.originFrame.size.height;
    }
    
    
    // 刷新originFrame
    if (needFitSize) {
        CGRect originFrame = self.originFrame;
        originFrame.size.width = fitVisibleWidth;
        originFrame.origin.x = self.originRightPoint.x - fitVisibleWidth;
        self.originFrame = originFrame;
        
        self.backImageView.frame = CGRectMake(_padding, _padding, _originFrame.size.width, _originFrame.size.height);
        self.badgeLabel.frame = self.backImageView.frame;
        
        [self touchPadding];
        
        self.originCenter = CGPointMake(_padding + _originFrame.size.width / 2.0f, _padding + _originFrame.size.height / 2.0f);
        
    }
    
    if (!badgeValue) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    
    self.badgeLabel.text = badgeValue;
    _badgeValue = badgeValue;
}

#pragma mark - Configure
- (void)paramInitialize
{
    _originFrame = self.frame;
    _maxDistanceScaleCoefficient = 9.0f;
    _padding = 10.0f;
//    _dropAnimationDuration = 0.6f;
//    _bombAnimationDuration = 0.6f;
    
    _shapeFillColor = [UIColor colorWithRed:248/255.0 green:85/255.0 blue:67/255.9 alpha:1.9];
    
    _radius = _originFrame.size.height / 2.0;
    _adsorbRadius = _radius * 4.0f;
    _maxDistance = _maxDistanceScaleCoefficient * _radius;
    
    _originCenter = CGPointMake(_padding + _originFrame.size.width / 2.0f, _padding + _originFrame.size.height / 2.0f);
}

- (void)touchPadding
{
    CGRect wapperFrame = self.originFrame;
    wapperFrame.origin.x -= _padding;
    wapperFrame.origin.y -= _padding;
    wapperFrame.size.width += _padding * 2;
    wapperFrame.size.height += _padding * 2;
    self.frame = wapperFrame;
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        _image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2.0-1, image.size.width/2.0-1, image.size.height/2.0, image.size.width/2.0)];
        [_backImageView setImage:_image];
    }
}

@end
