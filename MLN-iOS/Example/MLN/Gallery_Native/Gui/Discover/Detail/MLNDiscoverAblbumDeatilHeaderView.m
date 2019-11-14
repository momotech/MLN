//
//  MLNDiscoverAblbumDeatilHeaderView.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNDiscoverAblbumDeatilHeaderView.h"
#import "MLNDiscoverTagView.h"
#import "MLNNativeTabSegmentView.h"
#import "MLNGalleryNative.h"
#import <UIImageView+WebCache.h>

@interface MLNDiscoverAblbumDeatilHeaderView()

@property (nonatomic, strong) UIImageView *albumImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIImageView *collectImageView;
@property (nonatomic, strong) UILabel *collectCountLabel;
@property (nonatomic, strong) UIImageView *lookImageView;
@property (nonatomic, strong) UILabel *lookCountLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *recommendLabel;
@property (nonatomic, strong) MLNDiscoverTagView *tagView;
@property (nonatomic, strong) MLNNativeTabSegmentView *tabSegementView;
@property (nonatomic, strong) UIView *seperatorView;

@end

@implementation MLNDiscoverAblbumDeatilHeaderView

- (void)reloadWithData:(NSArray *)dataList
{
    if (dataList.count <= 0) {
        return;
    }
    NSString *albumImageString = [dataList[1] valueForKey:@"pic_radio"];
    [self.albumImageView sd_setImageWithURL:[NSURL URLWithString:albumImageString]];
    NSMutableArray *authorArray = [NSMutableArray array];
    NSInteger itemCount = dataList.count;
    for (NSInteger i = 0; i < itemCount; i++) {
        if (i >= 3) {
            break;
        }
        NSDictionary *dict = dataList[i];
        NSString *authorString = [dict valueForKey:@"author"];
        if (authorString) {
            [authorArray addObject:authorString];
        }
    }
    [self.tagView reloadWithDataList:authorArray];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1.0];
    
    CGFloat margin = 10;
    CGFloat albumImageViewWH = 100;
    CGFloat albumImageViewY = 20;
    self.albumImageView.frame = CGRectMake(margin, albumImageViewY, albumImageViewWH, albumImageViewWH);
    
    CGFloat followButtonW = 80;
    CGFloat followButtonH = 30;
    CGFloat followButtonX = kScreenWidth - followButtonW - margin;
    self.followButton.frame = CGRectMake(followButtonX, albumImageViewY, followButtonW, followButtonH);
    
    [self.titleLabel sizeToFit];
    CGSize titleLabelSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
    CGFloat titleLabelX = margin + albumImageViewWH + 10;
    CGFloat titleLabelY = albumImageViewY;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelSize.width, titleLabelSize.height);
    
    CGFloat collectImageViewWH = 20;
    CGFloat collectImageViewX = titleLabelX;
    CGFloat collectImageViewY = titleLabelY + titleLabelSize.height + 10;
    self.collectImageView.frame = CGRectMake(collectImageViewX, collectImageViewY, collectImageViewWH, collectImageViewWH);
    
    CGSize collectCountLabelSize = [self.collectCountLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat collectCountLabelX = collectImageViewX + collectImageViewWH + 5;
    CGFloat collectCountLabelY = collectImageViewY;
    self.collectCountLabel.frame = CGRectMake(collectCountLabelX, collectCountLabelY, collectCountLabelSize.width, collectCountLabelSize.height);
    
    CGFloat lookImageViewWH = 20;
    CGFloat lookImageViewX = collectCountLabelX + collectCountLabelSize.width + 5;
    CGFloat lookImageViewY = titleLabelY + titleLabelSize.height + 10;
    self.lookImageView.frame = CGRectMake(lookImageViewX, lookImageViewY, lookImageViewWH, lookImageViewWH);
    
    CGSize lookCountLabelSize = [self.collectCountLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat lookCountLabelX = lookImageViewX + lookImageViewWH + 5;
    CGFloat lookCountLabelY = lookImageViewY;
    self.lookCountLabel.frame = CGRectMake(lookCountLabelX, lookCountLabelY, lookCountLabelSize.width, lookCountLabelSize.height);
    
    CGFloat avatarImageViewWH = 20;
    CGFloat avatarImageViewX = titleLabelX;
    CGFloat avatarImageViewY = albumImageViewY + albumImageViewWH - avatarImageViewWH;
    self.avatarImageView.frame = CGRectMake(avatarImageViewX, avatarImageViewY, avatarImageViewWH, avatarImageViewWH);
    
    [self.nameLabel sizeToFit];
    CGSize nameLabelSize = [self.nameLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat nameLabelX = avatarImageViewX + avatarImageViewWH + 5;
    CGFloat nameLabelY = (avatarImageViewWH - nameLabelSize.height)/2.0 + avatarImageViewY;
    self.nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelSize.width, nameLabelSize.height);
    
    [self.recommendLabel sizeToFit];
    CGFloat recommendHeight = 20;
    CGFloat recommendLabelY = avatarImageViewY + avatarImageViewWH + 20;
    CGSize recommendLabelSize = [self.recommendLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    self.recommendLabel.frame = CGRectMake(margin, recommendLabelY, recommendLabelSize.width, recommendHeight);
    
    CGFloat tagButtonX = margin + recommendLabelSize.width+ 3;
    CGFloat tagButtonY = recommendLabelY;
    CGFloat tagButtonW = kScreenWidth - tagButtonX - margin;
    self.tagView.frame = CGRectMake(tagButtonX, tagButtonY, tagButtonW, recommendHeight);
    
    CGFloat tabSegementY = tagButtonY + recommendHeight + 10;
    CGFloat tabSegementHeight = 50;
    self.tabSegementView.frame = CGRectMake(0, tabSegementY, kScreenWidth, tabSegementHeight);
    [self setCornerRadius:10 toView:self.tabSegementView];
    
    self.seperatorView.frame = CGRectMake(0, tabSegementY + tabSegementHeight, kScreenWidth, 0.5);
}


#pragma mark - Private method
- (UIImageView *)albumImageView
{
    if (!_albumImageView) {
        _albumImageView = [[UIImageView alloc] init];
        _albumImageView.layer.cornerRadius = 6;
        _albumImageView.layer.masksToBounds = YES;
        [self addSubview:_albumImageView];
    }
    return _albumImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"一周穿搭不重样";
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)followButton
{
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_followButton setTitle:@"+ 关注" forState:UIControlStateNormal];
        _followButton.layer.cornerRadius = 3;
        _followButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _followButton.layer.borderWidth = 0.5;
        [self addSubview:_followButton];
    }
    return _followButton;
}

- (UIImageView *)collectImageView
{
    if (!_collectImageView) {
        _collectImageView = [[UIImageView alloc] init];
        [_collectImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_star.png"]];
        [self addSubview:_collectImageView];
    }
    return _collectImageView;
}

- (UILabel *)collectCountLabel
{
    if (!_collectCountLabel) {
        _collectCountLabel = [[UILabel alloc] init];
        _collectCountLabel.font = [UIFont systemFontOfSize:12];
        _collectCountLabel.textColor = [UIColor whiteColor];
        _collectCountLabel.text = @"200篇";
        [self addSubview:_collectCountLabel];
    }
    return _collectCountLabel;
}

- (UIImageView *)lookImageView
{
    if (!_lookImageView) {
        _lookImageView = [[UIImageView alloc] init];
        [_lookImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/10/18/1571393656549-mls_scan.png"]];
        [self addSubview:_lookImageView];
    }
    return _lookImageView;
}


- (UILabel *)lookCountLabel
{
    if (!_lookCountLabel) {
        _lookCountLabel = [[UILabel alloc] init];
        _lookCountLabel.font = [UIFont systemFontOfSize:12];
        _lookCountLabel.textColor = [UIColor whiteColor];
        _lookCountLabel.text = @"6790";
        [self addSubview:_lookCountLabel];
    }
    return _lookCountLabel;
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_header.png"]];
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"小美酱Pick榜 创建";
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)recommendLabel
{
    if (!_recommendLabel) {
        _recommendLabel = [[UILabel alloc] init];
        _recommendLabel.text = @"相关灵感集：";
        _recommendLabel.textColor = [UIColor whiteColor];
        _recommendLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_recommendLabel];
    }
    return _recommendLabel;
}

- (MLNDiscoverTagView *)tagView
{
    if (!_tagView) {
        _tagView = [[MLNDiscoverTagView alloc] init];
        _tagView.normalBackgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0];
        _tagView.normalTextColor = [UIColor whiteColor];
        [self addSubview:_tagView];
    }
    return _tagView;
}

- (MLNNativeTabSegmentView *)tabSegementView
{
    if (!_tabSegementView) {
        _tabSegementView = [[MLNNativeTabSegmentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50) segmentTitles:@[@"热门", @"最新"] tapBlock:^(MLNNativeTabSegmentView * _Nonnull tapView, NSInteger index) {
            if (self.selectBlock) {
                self.selectBlock();
            }
        }];
        _tabSegementView.backgroundColor = [UIColor whiteColor];
        [_tabSegementView lua_setAlignment:MLNNativeTabSegmentAlignmentLeft];
        [self addSubview:_tabSegementView];
    }
    return _tabSegementView;
}

- (UIView *)seperatorView
{
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
        [self addSubview:_seperatorView];
    }
    return _seperatorView;
}


#pragma mark - Util

- (void)setCornerRadius:(CGFloat)cornerRadius toView:(UIView *)view
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.lineWidth = 4;
    maskLayer.lineCap = kCALineCapSquare;
    maskLayer.path = bezierPath.CGPath;
    view.layer.mask = maskLayer;
}

@end
