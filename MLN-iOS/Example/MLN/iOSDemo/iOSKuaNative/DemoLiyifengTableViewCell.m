//
//  DemoLiyifengTableViewCell.m
//  MyFirstDemo
//
//  Created by MOMO on 2020/9/2.
//  Copyright © 2020 MOMO. All rights reserved.
//

#define ssRGB(r, g, b) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define ssRGBAlpha(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#import <Masonry/Masonry.h>

#import <UIImageView+WebCache.h>

#import "DemoLiyifengTableViewCell.h"

@implementation DemoLiyifengTableViewCell{
    UIImageView *_iconImg;
    UILabel *_nameLabel;
    UILabel *_gradeLabel;
    UILabel *_timeLabel;
    UILabel *_commentLabel;
    UIView  *_replyBackgroundView;
    UILabel *_replyNameLabel1;
    UILabel *_replyLabel1;
    UILabel *_replyNameLabel2;
    UILabel *_replyLabel2;
    UILabel *_moreReplyLabel;
    UIImageView *_praiseImg;
    UILabel *_praiseNumLabel;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _iconImg = [UIImageView new];
        [self.contentView addSubview:_iconImg];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
        
        _gradeLabel = [UILabel new];
        _gradeLabel.font = [UIFont systemFontOfSize:13];
        _gradeLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_gradeLabel];
        
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_timeLabel];
        
        _commentLabel = [UILabel new];
        _commentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_commentLabel];
        
        _replyBackgroundView = [UIView new];
        _replyBackgroundView.backgroundColor = ssRGBAlpha(211,211,211,0.5);
        [self.contentView addSubview:_replyBackgroundView];
        
        _replyNameLabel1 = [UILabel new];
        _replyNameLabel1.font = [UIFont systemFontOfSize:14];
        _replyNameLabel1.textColor = ssRGB(0,206,209);
        [self.contentView addSubview:_replyNameLabel1];
        
        _replyLabel1 = [UILabel new];
        _replyLabel1.font = [UIFont systemFontOfSize:14];
        _replyLabel1.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_replyLabel1];
        
        _replyNameLabel2 = [UILabel new];
        _replyNameLabel2.font = [UIFont systemFontOfSize:14];
        _replyNameLabel2.textColor = ssRGB(0,206,209);
        [self.contentView addSubview:_replyNameLabel2];
        
        _replyLabel2 = [UILabel new];
        _replyLabel2.font = [UIFont systemFontOfSize:14];
        _replyLabel2.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_replyLabel2];
        
        _moreReplyLabel = [UILabel new];
        _moreReplyLabel.font = [UIFont systemFontOfSize:14];
        _moreReplyLabel.textColor = ssRGB(0,206,209);
        [self.contentView addSubview:_moreReplyLabel];
        
        _praiseImg = [UIImageView new];
        [self.contentView addSubview:_praiseImg];
        
        _praiseNumLabel = [UILabel new];
        _praiseNumLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_praiseNumLabel];
                
        [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(20);
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(20);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
            
        }];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(25);
            make.left.mas_equalTo(_iconImg.mas_right).mas_offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(10);
        }];
                       
        [_gradeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(55);
            make.left.mas_equalTo(_iconImg.mas_right).mas_offset(8);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(10);
        }];
        
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(55);
            make.left.mas_equalTo(_gradeLabel.mas_right).mas_offset(5);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(10);
            
        }];
        
        [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_iconImg.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(25);
            make.width.mas_equalTo(400);
//            make.height.mas_equalTo(10);
            
        }];
        
        [_replyBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_commentLabel.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(25);
            make.width.mas_equalTo(330);
            make.height.mas_equalTo(80);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-5);
            
        }];
        
        [_replyNameLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_replyBackgroundView.mas_top).mas_offset(10);
            make.left.mas_equalTo(_replyBackgroundView.mas_left).mas_offset(10);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(10);
            
        }];
        
        [_replyLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_replyBackgroundView.mas_top).mas_offset(10);
            make.left.mas_equalTo(_replyNameLabel1.mas_right).mas_offset(5);
            make.width.mas_equalTo(400);
            make.height.mas_equalTo(10);
        }];
        
        [_replyNameLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_replyLabel1.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(_replyBackgroundView.mas_left).mas_offset(10);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(10);
            
        }];
        
        [_replyLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_replyLabel1.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(_replyNameLabel2.mas_right).mas_offset(5);
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(10);
            
        }];
        
        [_moreReplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_replyLabel2.mas_bottom).mas_offset(15);
            make.left.mas_equalTo(_replyBackgroundView.mas_left).mas_offset(250);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(10);
        }];
        
        [_praiseImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(35);
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(290);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        [_praiseNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(35);
            make.left.mas_equalTo(_praiseImg.mas_right).mas_offset(5);
            
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(20);
                  
        }];
                       
                       
        
    }
    return self;
}

- (void)setLiyifengTableViewCellModel:(DemoLiyifengModel *)LiyifengTableViewCellModel {
    _LiyifengTableViewCellModel = LiyifengTableViewCellModel;
    [_iconImg sd_setImageWithURL:[NSURL URLWithString:_LiyifengTableViewCellModel.icon]];
    _nameLabel.text = _LiyifengTableViewCellModel.name;
    _gradeLabel.text = _LiyifengTableViewCellModel.grade;
    _timeLabel.text = _LiyifengTableViewCellModel.time;
    _commentLabel.text = _LiyifengTableViewCellModel.comment;
    _replyNameLabel1.text = _LiyifengTableViewCellModel.replyName1;
    _replyLabel1.text = _LiyifengTableViewCellModel.reply1;
    _replyNameLabel2.text = _LiyifengTableViewCellModel.replyName2;
    _replyLabel2.text = _LiyifengTableViewCellModel.reply2;
    _moreReplyLabel.text = _LiyifengTableViewCellModel.moreReply;
    [_praiseImg sd_setImageWithURL:[NSURL URLWithString:_LiyifengTableViewCellModel.praise]];
    _praiseNumLabel.text = _LiyifengTableViewCellModel.praiseNum;
//    [self.contentView setNeedsUpdateConstraints];
//    [self.contentView updateConstraintsIfNeeded];
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
}

@end
