//
//  MLNDiscoverAlbumDetailCell.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNDiscoverAlbumDetailCell.h"
#import <UIImageView+WebCache.h>

#define kTextColor [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]

@interface MLNDiscoverAlbumDetailCell()

@property (nonatomic, strong) UIImageView *albumImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *likeImageView;
@property (nonatomic, strong) UILabel *likeCountLabel;

@end

@implementation MLNDiscoverAlbumDetailCell

- (void)reloadWithData:(NSDictionary *)data
{
    if (data.allKeys.count <= 0) {
        return;
    }
    NSString *albumImageString = [NSString stringWithFormat:@"%@", [data valueForKey:@"pic_big"]];
    [self.albumImageView sd_setImageWithURL:[NSURL URLWithString:albumImageString]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@%@", [data valueForKey:@"title"], [data valueForKey:@"si_proxycompany"], [data valueForKey:@"album_title"]];
    NSString *avatarImageString = [NSString stringWithFormat:@"%@", [data valueForKey:@"pic_small"]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarImageString]];
    self.nameLabel.text = [NSString stringWithFormat:@"%@", [data valueForKey:@"artist_name"]];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", [data valueForKey:@"file_duration"]];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cellWidth  = self.bounds.size.width;
    CGFloat albumImageViewH = 200;
    self.albumImageView.frame = CGRectMake(0, 0, cellWidth, albumImageViewH);
    
    CGFloat titleLabelY = albumImageViewH + 5;
    CGSize titleLabelSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(cellWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    self.titleLabel.frame = CGRectMake(0, titleLabelY, cellWidth, titleLabelSize.height);
    
    CGFloat avatarImageViewWH = 20;
    CGFloat avatarImageViewY = titleLabelY + titleLabelSize.height + 5;
    self.avatarImageView.frame = CGRectMake(0, avatarImageViewY, avatarImageViewWH, avatarImageViewWH);

    [self.nameLabel sizeToFit];
    CGSize nameLabelSize = [self.nameLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    CGFloat nameLabelX = avatarImageViewWH + 5;
    CGFloat nameLabelY = (avatarImageViewWH - nameLabelSize.height)/2.0 + avatarImageViewY;
    self.nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelSize.width, nameLabelSize.height);
    
    [self.likeCountLabel sizeToFit];
    CGSize likeCountLabelSize = [self.likeCountLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    CGFloat likeCountLabelY = nameLabelY;
    CGFloat likeCountLabelX = cellWidth - likeCountLabelSize.width - 5;
    self.likeCountLabel.frame = CGRectMake(likeCountLabelX, likeCountLabelY, likeCountLabelSize.width, likeCountLabelSize.height);

    CGFloat likeImageViewWH = avatarImageViewWH;
    CGFloat likeImageViewX = likeCountLabelX - 5 - likeImageViewWH;
    CGFloat likeImageViewY = avatarImageViewY;
    self.likeImageView.frame = CGRectMake(likeImageViewX, likeImageViewY, likeImageViewWH, likeImageViewWH);
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
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = kTextColor;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 10;
        _avatarImageView.layer.masksToBounds = YES;
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:10];
        _nameLabel.textColor = kTextColor;
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIImageView *)likeImageView
{
    if (!_likeImageView) {
        _likeImageView = [[UIImageView alloc] init];
        _likeImageView.userInteractionEnabled = YES;
        [_likeImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/10/22/1571734558042-mls_love.png"]];
        [self addSubview:_likeImageView];
    }
    return _likeImageView;
}

- (UILabel *)likeCountLabel
{
    if (!_likeCountLabel) {
        _likeCountLabel = [[UILabel alloc] init];
        _likeCountLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_likeCountLabel];
    }
    return _likeCountLabel;
}

@end
