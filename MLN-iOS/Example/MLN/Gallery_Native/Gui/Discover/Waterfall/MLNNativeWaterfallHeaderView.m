//
//  MLNNativeWaterfallHeaderView.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/7.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNNativeWaterfallHeaderView.h"
#import "MLNGalleryNative.h"
#import <UIView+Toast.h>
#import "MLNDiscoverInspirCategoryView.h"
#import <UIImageView+WebCache.h>


@interface MLNNativeWaterfallHeaderView()

@property (nonatomic, strong) UILabel *searchLabel;
@property (nonatomic, strong) UIImageView *guideImageView;
@property (nonatomic, strong) UIImageView *welfareImageView;
@property (nonatomic, strong) UIView *annualTaskView;
@property (nonatomic, strong) UILabel *taskLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIView *seperatorView;
@property (nonatomic, strong) UILabel *inspirLabel;
@property (nonatomic, strong) MLNDiscoverInspirCategoryView *categoryView;
@property (nonatomic, assign) BOOL hasLiked;

@end

@implementation MLNNativeWaterfallHeaderView

- (void)reloadWithData:(NSDictionary *)dict
{
    [self.categoryView reloadWithData:@[@"推荐", @"穿搭", @"美妆", @"探店", @"旅行"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 10;
    CGFloat searchLabelWidth = kScreenWidth - 40;
    CGFloat searchLabelHeight = 36;
    CGFloat searchLabelY = 10;
    CGFloat searchLabelX = (kScreenWidth - searchLabelWidth)/2.0;
    self.searchLabel.frame = CGRectMake(searchLabelX, searchLabelY, searchLabelWidth, searchLabelHeight);
    
    CGFloat guideImageViewW = kScreenWidth - 2 * margin;
    CGFloat guideImageViewH = 100;
    CGFloat guideImageViewY = searchLabelY + searchLabelHeight + 10;
    self.guideImageView.frame = CGRectMake(margin, guideImageViewY, guideImageViewW, guideImageViewH);
    
    CGFloat welfareImageViewW = guideImageViewW;
    CGFloat welfareImageViewH = 60;
    CGFloat welfareImageViewY = guideImageViewY + guideImageViewH + 10;
    self.welfareImageView.frame = CGRectMake(margin, welfareImageViewY, welfareImageViewW, welfareImageViewH);
    
    CGFloat annualTaskViewW = welfareImageViewW;
    CGFloat annualTaskViewH = 30;
    CGFloat annualTaskViewY = welfareImageViewY + welfareImageViewH;
    self.annualTaskView.frame = CGRectMake(margin, annualTaskViewY, annualTaskViewW, annualTaskViewH);
    
    CGSize taskLabelSize = [self.taskLabel.text boundingRectWithSize:CGSizeMake(annualTaskViewW, annualTaskViewH) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size;
    CGFloat taskLabelY = (annualTaskViewH - taskLabelSize.height)/2.0;
    self.taskLabel.frame = CGRectMake(0, taskLabelY, taskLabelSize.width, taskLabelSize.height);
    
    CGFloat likeButtonW = 50;
    CGFloat likeButtonH = 20;
    CGFloat likeButtonX = annualTaskViewW - likeButtonW;
    CGFloat likeButtonY = (annualTaskViewH - likeButtonH)/2.0;
    self.likeButton.frame = CGRectMake(likeButtonX, likeButtonY, likeButtonW, likeButtonH);
    
    CGFloat seperatorViewY = annualTaskViewY + annualTaskViewH;
    self.seperatorView.frame = CGRectMake(margin, seperatorViewY, annualTaskViewW, 1);
    
    CGSize inspirLabelSize = [self.inspirLabel.text boundingRectWithSize:CGSizeMake(annualTaskViewW, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil].size;
    CGFloat inspirLabelY = seperatorViewY + 1 + 10;
    self.inspirLabel.frame = CGRectMake(margin, inspirLabelY, inspirLabelSize.width, inspirLabelSize.height);
    
    CGFloat categoryY = inspirLabelY + inspirLabelSize.height + 3;
    CGFloat categoryH = 20;
    self.categoryView.frame = CGRectMake(margin, categoryY, annualTaskViewW, categoryH);
}


#pragma mark - Action
- (void)search:(UIGestureRecognizer *)gesture
{
    [self makeToast:@"网红咖啡馆" duration:1.0 position:CSToastPositionCenter];
}

- (void)likeButtonClicked:(UIButton *)sender
{
    if (!self.hasLiked) {
        [sender setTitle:@"已赞👍" forState:UIControlStateNormal];
        self.hasLiked = YES;
    } else {
        [sender setTitle:@"去点赞" forState:UIControlStateNormal];
        self.hasLiked = NO;
    }
}

- (void)guideImageViewClicked:(UIGestureRecognizer *)gesture
{
    [self makeToast:@"请查看请使用指南" duration:1.0 position:CSToastPositionCenter];
}


- (void)welfareImageViewClicked:(UIGestureRecognizer *)gesture
{
    [self makeToast:@"直接去福利社换取福利哦" duration:1.0 position:CSToastPositionCenter];
}

#pragma mark - Private method
- (UILabel *)searchLabel
{
    if (!_searchLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 36)];
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:0.1];
        label.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:0.4];
        label.text = @"大家都在搜\"网红咖啡馆\"";
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 18;
        label.layer.masksToBounds = YES;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
        [label addGestureRecognizer:tapGesture];
        _searchLabel = label;
        [self addSubview:_searchLabel];
    }
    return _searchLabel;
}

- (UIImageView *)guideImageView
{
    if (!_guideImageView) {
        _guideImageView = [[UIImageView alloc] init];
        [_guideImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/27/1566877265808-meilishuoguide.png"]];
        _guideImageView.layer.cornerRadius = 5;
        _guideImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(guideImageViewClicked:)];
        [_guideImageView addGestureRecognizer:tapGesture];
        [self addSubview:_guideImageView];
    }
    return _guideImageView;
}

- (UIImageView *)welfareImageView
{
    if (!_welfareImageView) {
        _welfareImageView = [[UIImageView alloc] init];
        [_welfareImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/2019/08/27/1566877691900-welfare.png"]];
        _welfareImageView.layer.cornerRadius = 5;
        _welfareImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(welfareImageViewClicked:)];
        [_welfareImageView addGestureRecognizer:tapGesture];
        [self addSubview:_welfareImageView];
    }
    return _welfareImageView;
}

- (UIView *)annualTaskView
{
    if (!_annualTaskView) {
        _annualTaskView = [[UIView alloc] init];
        [self addSubview:_annualTaskView];
    }
    return _annualTaskView;
}

- (UILabel *)taskLabel
{
    if (!_taskLabel) {
        _taskLabel = [[UILabel alloc] init];
        NSString *placeHolderString = @"日常任务：点亮爱心，为内容点赞";
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:placeHolderString attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
        UIColor *deepGray = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0];
        [attriString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:deepGray} range:NSMakeRange(5, placeHolderString.length-5)];
        _taskLabel.attributedText = attriString;
        [self.annualTaskView addSubview:_taskLabel];
    }
    return _taskLabel;
}

- (UIButton *)likeButton
{
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_likeButton setTitleColor:[UIColor colorWithRed:204/255.0 green:137/255.0 blue:24/255.0 alpha:1.0] forState:UIControlStateNormal];
        _likeButton.layer.borderWidth = 0.5;
        _likeButton.layer.borderColor = [UIColor colorWithRed:204/255.0 green:137/255.0 blue:24/255.0 alpha:1.0].CGColor;
        _likeButton.layer.cornerRadius = 10;
        [_likeButton setTitle:@"点赞" forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.annualTaskView addSubview:_likeButton];
    }
    return _likeButton;
}

- (UIView *)seperatorView
{
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [self addSubview:_seperatorView];
    }
    return _seperatorView;
}

- (UILabel *)inspirLabel
{
    if (!_inspirLabel) {
        _inspirLabel = [[UILabel alloc] init];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"灵感集 / 探索更有趣的时髦生活" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
        UIColor *mediumGray = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(5, attributeString.length - 5)];
        [attributeString addAttribute:NSForegroundColorAttributeName value:mediumGray range:NSMakeRange(4, attributeString.length - 4)];
        _inspirLabel.attributedText = attributeString;
        [self addSubview:_inspirLabel];
    }
    return _inspirLabel;
}

- (MLNDiscoverInspirCategoryView *)categoryView
{
    if (!_categoryView) {
        _categoryView = [[MLNDiscoverInspirCategoryView alloc] init];
        [self addSubview:_categoryView];
    }
    return _categoryView;
}

@end
