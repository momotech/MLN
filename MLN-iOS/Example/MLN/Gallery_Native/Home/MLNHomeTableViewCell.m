//
//  MLNHomeTableViewCell.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNHomeTableViewCell.h"
#import "MLNGalleryNative.h"
#import <UIImageView+WebCache.h>
#import <SDCycleScrollView/SDCycleScrollView.h>
#import "MLNHomeDataHandler.h"
#import <UIView+Toast.h>

@interface MLNHomeTableViewCell()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *topContainerView;
@property (nonatomic, strong) UIImageView *avtarImageView;
@property (nonatomic, strong) UILabel *shopLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) SDCycleScrollView *viewPager;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *inspirContainerView;
@property (nonatomic, strong) UIImageView *inspirImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) UIImageView *ellipsisImageView;
@property (nonatomic, strong) UIImageView *likeImageView;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UIImageView *mesageImageView;
@property (nonatomic, strong) UILabel *messageCountLabel;
@property (nonatomic, strong) UIImageView *collectImageView;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL hasLiked;
@property (nonatomic, assign) BOOL hasCollect;
@end

@implementation MLNHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.avtarImageView];
    [self.topContainerView addSubview:self.shopLabel];
    [self.topContainerView addSubview:self.followButton];
    [self.containerView addSubview:self.viewPager];
    [self.containerView addSubview:self.descLabel];
    [self.containerView addSubview:self.inspirContainerView];
    [self.inspirContainerView addSubview:self.inspirImageView];
    [self.inspirContainerView addSubview:self.titleLabel];
    [self.inspirContainerView addSubview:self.subTitleLabel];
    [self.inspirContainerView addSubview:self.linkLabel];
    [self.containerView addSubview:self.bottomContainerView];
    [self.bottomContainerView addSubview:self.ellipsisImageView];
    [self.bottomContainerView addSubview:self.likeImageView];
    [self.bottomContainerView addSubview:self.likeCountLabel];
    [self.bottomContainerView addSubview:self.mesageImageView];
    [self.bottomContainerView addSubview:self.messageCountLabel];
    [self.bottomContainerView addSubview:self.collectImageView];
}

- (void)updateFollowButtonState:(BOOL)show
{
    self.followButton.hidden = !show;
}

- (void)reloadCellWithData:(NSDictionary *)dict
{
    [self.avtarImageView sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"itempic"]]];
    self.shopLabel.text = [dict valueForKey:@"sellernick"];
    NSMutableArray *pictureArray = [NSMutableArray new];
    NSInteger picCount = [MLNHomeDataHandler handler].dataList.count;
    for (NSInteger i = 0; i < picCount; i++) {
        if (i >= 9) {
            break;
        }
        NSDictionary *dict = [MLNHomeDataHandler handler].dataList[i];
        NSString *picUrlString = [dict valueForKey:@"itempic"];
        if (picUrlString) {
            [pictureArray addObject:picUrlString];
        }
    }
    [self.viewPager setImageURLStringsGroup:pictureArray];
    self.descLabel.text = [dict valueForKey:@"itemshorttitle"];
    [self.inspirImageView sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"itempic"]]];
    self.subTitleLabel.text = [dict valueForKey:@"itemshorttitle"];
    self.linkLabel.text = [NSString stringWithFormat:@"%@篇内容>", [dict valueForKey:@"couponmoney"]];
    self.likeCountLabel.text = [dict valueForKey:@"itemsale"];
    self.messageCountLabel.text = [dict valueForKey:@"general_index"];
    
    [self relayoutSubviews];
}


- (void)relayoutSubviews
{
    CGFloat topContainerViewH = 56;
    self.topContainerView.frame = CGRectMake(0, 0, kScreenWidth, topContainerViewH);
    CGFloat avatarImageViewWH = 36;
    CGFloat avatarImageViewX = 10;
    CGFloat avatarImageViewY = (topContainerViewH - avatarImageViewWH)/2.0;
    self.avtarImageView.frame = CGRectMake(avatarImageViewX, avatarImageViewY, avatarImageViewWH, avatarImageViewWH);
    
    CGSize shopLabelSize = [self.shopLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    CGFloat shopLabelX = avatarImageViewX + avatarImageViewWH + 8;
    CGFloat shopLabelY = (topContainerViewH - shopLabelSize.height) / 2.0;
    self.shopLabel.frame = CGRectMake(shopLabelX, shopLabelY, shopLabelSize.width, shopLabelSize.height);
    
    CGFloat followButtonW = 55;
    CGFloat followButtonH = 30;
    CGFloat followButtonX = kScreenWidth - followButtonW - 10;
    CGFloat followButtonY = (topContainerViewH - followButtonH) / 2.0;
    self.followButton.frame = CGRectMake(followButtonX, followButtonY, followButtonW, followButtonH);
    
    CGFloat viewPagerX = 0;
    CGFloat viewPagerY = topContainerViewH + 10;
    CGFloat viewPagerHeight = 320;
//    CGFloat viewPagerHeight = self.avtarImageView.image.size.height/self.avtarImageView.image.size.width * kScreenWidth;
    self.viewPager.frame = CGRectMake(viewPagerX, viewPagerY, kScreenWidth, viewPagerHeight);
    
    CGFloat descLabelX = 10;
    CGSize descLabelSize = [self.descLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.descLabel.font} context:nil].size;
    CGFloat descLabelY = viewPagerY + viewPagerHeight + 10;
    self.descLabel.frame = CGRectMake(descLabelX, descLabelY, descLabelSize.width, descLabelSize.height);
    
    CGFloat inspirContainerViewW = kScreenWidth - 20;
    CGFloat inspirContainerViewH = 50;
    CGFloat inspirContainerViewX = 10;
    CGFloat inspirContainerViewY = descLabelY + self.descLabel.frame.size.height + 10;
    self.inspirContainerView.frame = CGRectMake(inspirContainerViewX, inspirContainerViewY, inspirContainerViewW, inspirContainerViewH);
    
    CGFloat inspirImageViewWH = inspirContainerViewH;
    self.inspirImageView.frame = CGRectMake(0, 0, inspirImageViewWH, inspirImageViewWH);
    
    [self.linkLabel sizeToFit];
    CGSize linkLabelSize = CGSizeMake(85, 26);
    
    [self.titleLabel sizeToFit];
    CGFloat titleLabelX = inspirImageViewWH + 10;
    CGFloat titleLabelY = 10;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    
    CGSize subTitleLabelSize = [self.subTitleLabel sizeThatFits:CGSizeMake(inspirContainerViewW - linkLabelSize.width, inspirContainerViewH)];
    CGFloat subTitleLabelY = 33;
    self.subTitleLabel.frame = CGRectMake(titleLabelX, subTitleLabelY, subTitleLabelSize.width, subTitleLabelSize.height);
    
    CGFloat linkLabelX = inspirContainerViewW - linkLabelSize.width - 10;
    CGFloat linkLabelY = (inspirContainerViewH - linkLabelSize.height)/2.0;
    self.linkLabel.frame = CGRectMake(linkLabelX, linkLabelY, linkLabelSize.width + 10, linkLabelSize.height);
    
    CGFloat bottomContainerViewH = 50;
    CGFloat bottomContainerViewY = inspirContainerViewY + inspirContainerViewH + 10;
    self.bottomContainerView.frame = CGRectMake(0, bottomContainerViewY, kScreenWidth, bottomContainerViewH);
    CGFloat ellipsisImageViewWH = 25;
    CGFloat ellipsisImageViewY = (bottomContainerViewH - ellipsisImageViewWH)/2.0;
    self.ellipsisImageView.frame = CGRectMake(10, ellipsisImageViewY, ellipsisImageViewWH, ellipsisImageViewWH);
    
    CGFloat interactionBtnWH = 25;
    CGFloat collectImageViewY = (bottomContainerViewH - interactionBtnWH) / 2.0;
    CGFloat collectImageViewX = kScreenWidth - interactionBtnWH - 10;
    self.collectImageView.frame = CGRectMake(collectImageViewX, collectImageViewY, interactionBtnWH, interactionBtnWH);
    
    CGFloat countLabelW = 30;
    CGFloat countLabelH = 15;
    
    CGFloat messageImageViewX = collectImageViewX - 10 - countLabelW - interactionBtnWH;
    CGFloat messageImageViewY = collectImageViewY;
    self.mesageImageView.frame = CGRectMake(messageImageViewX, messageImageViewY, interactionBtnWH, interactionBtnWH);
    
    CGFloat messageCountLabelX = messageImageViewX + interactionBtnWH + 3;
    CGFloat messageCountLabelY = messageImageViewY;
    self.messageCountLabel.frame = CGRectMake(messageCountLabelX, messageCountLabelY, countLabelW, countLabelH);
    
    CGFloat likeImageViewX = messageImageViewX - 10 - countLabelW - interactionBtnWH;
    CGFloat likeImageViewY = messageImageViewY;
    self.likeImageView.frame = CGRectMake(likeImageViewX, likeImageViewY, interactionBtnWH, interactionBtnWH);
    
    CGFloat likeCountLabelX = likeImageViewX + interactionBtnWH + 3;
    CGFloat likeCountLabelY = messageImageViewY;
    self.likeCountLabel.frame = CGRectMake(likeCountLabelX, likeCountLabelY, countLabelW, countLabelH);
    
    CGFloat containerViewHeight = bottomContainerViewY + bottomContainerViewH;
    self.containerView.frame = CGRectMake(0, 0, kScreenWidth, containerViewHeight);
    self.cellHeight = containerViewHeight + 8;
}

#pragma mark - Action
- (void)followButtonClicked:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"+关注"]) {
        [sender setTitle:@"已关注" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"+关注" forState:UIControlStateNormal];
    }
}

- (void)ellipsisImageViewClicked:(UIGestureRecognizer *)gesture
{
    [self makeToast:@"分享给你的好友哦" duration:2.0 position:CSToastPositionCenter];
}

- (void)inspirContainerViewClicked:(UIGestureRecognizer *)gesture
{
    [self makeToast:@"灵感集里面还有更多内容哦" duration:2.0 position:CSToastPositionCenter];
}

- (void)likeImageViewClicked:(UIGestureRecognizer *)gesture
{
    if (self.hasLiked)
    {
        [self.likeImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/31/1567257871136-like.png"]];
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", @(self.likeCountLabel.text.integerValue - 1)];
        self.hasLiked = NO;
    } else {
        [self makeToast:@"点赞成功，购物基金+1" duration:1.0 position:CSToastPositionCenter];
        [self.likeImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/31/1567257871172-liked.png"]];
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", @(self.likeCountLabel.text.integerValue + 1)];
        self.hasLiked = YES;
    }
    [self scaleAnimationWithView:self.likeImageView];
}

- (void)messageImageViewClicked:(UIGestureRecognizer *)gesture
{
    NSString *message = [NSString stringWithFormat:@"%@条评论", self.messageCountLabel.text];
    [self makeToast:message duration:2.0 position:CSToastPositionCenter];
}

- (void)collectImageViewClicked:(UIGestureRecognizer *)gesture
{
    if (self.hasCollect)
    {
        [self.collectImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/31/1567258988643-collect.png"]];
        self.hasCollect = NO;
    } else {
        [self makeToast:@"收藏成功" duration:1.0 position:CSToastPositionCenter];
        [self.collectImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/31/1567258988643-collected.png"]];
        self.hasCollect = YES;
    }
    [self scaleAnimationWithView:self.collectImageView];
}

#pragma mark - Interaction button animation
- (void)scaleAnimationWithView:(UIView *)animationView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue = [NSNumber numberWithFloat:1.2];
    animation.duration = 0.25;
    animation.autoreverses = YES;
    [animationView.layer addAnimation:animation forKey:@"ScaleAnimaiton"];
}

#pragma mark - Private method
- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UIView *)topContainerView
{
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] init];
    }
    return _topContainerView;
}

- (UIImageView *)avtarImageView
{
    if (!_avtarImageView) {
        _avtarImageView = [[UIImageView alloc] init];
        _avtarImageView.layer.cornerRadius = 18;
        _avtarImageView.layer.masksToBounds = YES;
    }
    return _avtarImageView;
}

- (UILabel *)shopLabel
{
    if (!_shopLabel) {
        _shopLabel = [[UILabel alloc] init];
        _shopLabel.font = [UIFont systemFontOfSize:14];
        _shopLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _shopLabel;
}

- (UIButton *)followButton
{
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_followButton setTitle:@"+关注" forState:UIControlStateNormal];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _followButton.layer.cornerRadius = 3;
        _followButton.layer.borderWidth = 1.0;
        _followButton.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0].CGColor;
        [_followButton addTarget:self action:@selector(followButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

- (SDCycleScrollView *)viewPager
{
    if (!_viewPager) {
        _viewPager = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero imageURLStringsGroup:nil];
        _viewPager.autoScroll = NO;
    }
    return _viewPager;
}


- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:15];
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.numberOfLines = 0;
    }
    
    return _descLabel;
}

- (UIView *)inspirContainerView
{
    if (!_inspirContainerView) {
        _inspirContainerView = [[UIView alloc] init];
        _inspirContainerView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inspirContainerViewClicked:)];
        [_inspirContainerView addGestureRecognizer:tapGesture];
    }
    return _inspirContainerView;
}

- (UIImageView *)inspirImageView
{
    if (!_inspirImageView) {
        _inspirImageView = [[UIImageView alloc] init];
    }
    return _inspirImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = @"来自灵感集";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.numberOfLines = 1;
    }
    return _subTitleLabel;
}

- (UILabel *)linkLabel
{
    if (!_linkLabel) {
        _linkLabel = [[UILabel alloc] init];
        _linkLabel.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
        _linkLabel.layer.cornerRadius = 12;
        _linkLabel.layer.masksToBounds = YES;
        _linkLabel.font = [UIFont systemFontOfSize:12];
        _linkLabel.textAlignment = NSTextAlignmentCenter;
        _linkLabel.numberOfLines = 1;
    }
    return _linkLabel;
}

- (UIView *)bottomContainerView
{
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
    }
    return _bottomContainerView;
}

- (UIImageView *)ellipsisImageView
{
    if (!_ellipsisImageView) {
        _ellipsisImageView = [[UIImageView alloc] init];
        [_ellipsisImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/28/1566958902005-share.png"]];
        _ellipsisImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ellipsisImageViewClicked:)];
        [_ellipsisImageView addGestureRecognizer:tapGesture];
    }
    return _ellipsisImageView;
}

- (UIImageView *)likeImageView
{
    if (!_likeImageView) {
        _likeImageView = [[UIImageView alloc] init];
        [_likeImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/31/1567257871136-like.png"]];
        _likeImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImageViewClicked:)];
        [_likeImageView addGestureRecognizer:tapGesture];
    }
    return _likeImageView;
}

- (UILabel *)likeCountLabel
{
    if (!_likeCountLabel) {
        _likeCountLabel = [[UILabel alloc] init];
        _likeCountLabel.font = [UIFont systemFontOfSize:12];
        _likeCountLabel.textAlignment = NSTextAlignmentCenter;
        _likeCountLabel.numberOfLines = 1;
    }
    return _likeCountLabel;
}

- (UIImageView *)mesageImageView
{
    if (!_mesageImageView) {
        _mesageImageView = [[UIImageView alloc] init];
        [_mesageImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/28/1566958902036-comment.png"]];
        _mesageImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageImageViewClicked:)];
        [_mesageImageView addGestureRecognizer:tapGesture];
    }
    return _mesageImageView;
}

- (UILabel *)messageCountLabel
{
    if (!_messageCountLabel) {
        _messageCountLabel = [[UILabel alloc] init];
        _messageCountLabel.font = [UIFont systemFontOfSize:12];
        _messageCountLabel.textAlignment = NSTextAlignmentCenter;
        _messageCountLabel.numberOfLines = 1;
    }
    return _messageCountLabel;
}

- (UIImageView *)collectImageView
{
    if (!_collectImageView) {
        _collectImageView = [[UIImageView alloc] init];
        [_collectImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/31/1567258988643-collect.png"]];
        _collectImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectImageViewClicked:)];
        [_collectImageView addGestureRecognizer:tapGesture];
    }
    return _collectImageView;
}
@end
