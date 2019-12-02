//
//  MLNNativeWaterfallViewCell.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/7.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNNativeWaterfallViewCell.h"
#import <UIImageView+WebCache.h>

@interface MLNNativeWaterfallViewCell()
@property (nonatomic, strong) UIImageView *albumImageView;
@property (nonatomic, strong) UIImageView *collectImageView;
@property (nonatomic, strong) UILabel *collectLabel;
@property (nonatomic, strong) UIImageView *watchImageView;
@property (nonatomic, strong) UILabel *watchLabel;
@property (nonatomic, strong) UILabel *albumLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation MLNNativeWaterfallViewCell

- (void)reloadWithData:(NSDictionary *)dict
{
    NSString *albumImageString = [dict valueForKey:@"album_500_500"];
    [self.albumImageView sd_setImageWithURL:[NSURL URLWithString:albumImageString]];
    self.collectLabel.text = [NSString stringWithFormat:@"%@篇", [dict valueForKey:@"rank"]];
    self.watchLabel.text = [NSString stringWithFormat:@"%@", [dict valueForKey:@"file_duration"]];
    self.albumLabel.text = [NSString stringWithFormat:@"%@", [dict valueForKey:@"title"]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:albumImageString]];
    self.contentLabel.text = [NSString stringWithFormat:@"更新了%@篇内容", [dict valueForKey:@"rank"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cellWidth = self.bounds.size.width;
    CGFloat albumImageViewH = self.bounds.size.height - 50;
    self.albumImageView.frame = CGRectMake(0, 0, cellWidth, albumImageViewH);
    
    CGFloat collectImageViewWH = 10;
    CGFloat collectImageViewX = 10;
    CGFloat collectImageViewY = albumImageViewH - 10 - collectImageViewWH;
    self.collectImageView.frame = CGRectMake(collectImageViewX, collectImageViewY, collectImageViewWH, collectImageViewWH);
    
    CGSize collectLabelSize = [self.collectLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    CGFloat collectLabelX = collectImageViewX + collectImageViewWH + 5;
    CGFloat collectLabelY = collectImageViewY;
    self.collectLabel.frame = CGRectMake(collectLabelX, collectLabelY, collectLabelSize.width, collectLabelSize.height);
    
    CGFloat watchImageViewWH = 10;
    CGFloat watchImageViewX = collectLabelX + collectLabelSize.width + 10;
    CGFloat watchImageViewY = albumImageViewH - 10 - collectImageViewWH;
    self.watchImageView.frame = CGRectMake(watchImageViewX, watchImageViewY, watchImageViewWH, watchImageViewWH);
    
    CGSize watchLabelSize = [self.collectLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    CGFloat watchLabelX = watchImageViewX + watchImageViewWH + 5;
    CGFloat watchLabelY = collectImageViewY;
    self.watchLabel.frame = CGRectMake(watchLabelX, watchLabelY, watchLabelSize.width, watchLabelSize.height);
    
    CGSize albumLabelSize = [self.albumLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat albumLabelY = albumImageViewH + 10;
    self.albumLabel.frame = CGRectMake(0, albumLabelY, cellWidth, albumLabelSize.height);
    
    CGFloat avatarImageViewWH = 10;
    CGFloat avatarImageViewY = albumLabelY + albumLabelSize.height;
    self.avatarImageView.frame = CGRectMake(0, avatarImageViewY, avatarImageViewWH, avatarImageViewWH);
    
    CGSize contentLabelSize = [self.contentLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat contentLabelX = avatarImageViewWH + 5;
    CGFloat contentLabelY = avatarImageViewY + (avatarImageViewWH - contentLabelSize.height)/2;
    self.contentLabel.frame = CGRectMake(contentLabelX, contentLabelY, contentLabelSize.width, contentLabelSize.height);
}


#pragma mark - Private method

- (UIImageView *)albumImageView
{
    if (!_albumImageView) {
        _albumImageView = [[UIImageView alloc] init];
        _albumImageView.layer.cornerRadius = 8;
        _albumImageView.layer.masksToBounds = YES;
        [self addSubview:_albumImageView];
    }
    return _albumImageView;
}

- (UIImageView *)collectImageView
{
    if (!_collectImageView) {
        _collectImageView = [[UIImageView alloc] init];
        [_collectImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/28/1566999785245-favor.png"]];
        [self addSubview:_collectImageView];
    }
    return _collectImageView;
}

- (UILabel *)collectLabel
{
    if (!_collectLabel) {
        _collectLabel = [[UILabel alloc] init];
        _collectLabel.textColor = [UIColor whiteColor];
        _collectLabel.font = [UIFont systemFontOfSize:8];
        [self addSubview:_collectLabel];
    }
    return _collectLabel;
}

- (UIImageView *)watchImageView
{
    if (!_watchImageView) {
        _watchImageView = [[UIImageView alloc] init];
        [_watchImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/28/1566999801782-look.png"]];
        [self addSubview:_watchImageView];
    }
    return _watchImageView;
}

- (UILabel *)watchLabel
{
    if (!_watchLabel) {
        _watchLabel = [[UILabel alloc] init];
        _watchLabel.font = [UIFont systemFontOfSize:8];
        _watchLabel.textColor = [UIColor whiteColor];
        [self addSubview:_watchLabel];
    }
    return _watchLabel;
}

- (UILabel *)albumLabel
{
    if (!_albumLabel) {
        _albumLabel = [[UILabel alloc] init];
        _albumLabel.font = [UIFont systemFontOfSize:12];
        _albumLabel.textColor = [UIColor blackColor];
        [self addSubview:_albumLabel];
    }
    return _albumLabel;
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 8;
        _avatarImageView.layer.masksToBounds = YES;
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:8];
        _contentLabel.textColor = [UIColor grayColor];
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

@end
