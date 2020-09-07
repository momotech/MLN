//
//  DemoLiyifengTableViewCell.m
//  MyFirstDemo
//
//  Created by MOMO on 2020/9/2.
//  Copyright © 2020 MOMO. All rights reserved.
//

#define ssRGB(r, g, b) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define ssRGBAlpha(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

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
        
        _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(20,20, 50, 50)];
        [self.contentView addSubview:_iconImg];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75,30, 100, 10)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
        
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(72,56, 100, 10)];
        _gradeLabel.font = [UIFont systemFontOfSize:13];
        _gradeLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_gradeLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(140,56, 150, 10)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_timeLabel];
        
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,78, 400, 10)];
        _commentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_commentLabel];
        
        _replyBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(35,100, 315, 80)];
        _replyBackgroundView.backgroundColor = ssRGBAlpha(211,211,211,0.5);
        [self.contentView addSubview:_replyBackgroundView];
        
        _replyNameLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(40,110, 400, 10)];
        _replyNameLabel1.font = [UIFont systemFontOfSize:14];
        _replyNameLabel1.textColor = ssRGB(0,206,209);
        [self.contentView addSubview:_replyNameLabel1];
        
        _replyLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(93,110, 400, 10)];
        _replyLabel1.font = [UIFont systemFontOfSize:14];
        _replyLabel1.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_replyLabel1];
        
        _replyNameLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(40,130, 400, 10)];
        _replyNameLabel2.font = [UIFont systemFontOfSize:14];
        _replyNameLabel2.textColor = ssRGB(0,206,209);
        [self.contentView addSubview:_replyNameLabel2];
        
        _replyLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(118,130, 400, 10)];
        _replyLabel2.font = [UIFont systemFontOfSize:14];
        _replyLabel2.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_replyLabel2];
        
        _moreReplyLabel = [[UILabel alloc] initWithFrame:CGRectMake(270,155, 100, 10)];
        _moreReplyLabel.font = [UIFont systemFontOfSize:14];
        _moreReplyLabel.textColor = ssRGB(0,206,209);
        [self.contentView addSubview:_moreReplyLabel];
        
        _praiseImg = [[UIImageView alloc] initWithFrame:CGRectMake(290,30, 20, 20)];
        [self.contentView addSubview:_praiseImg];
        
        _praiseNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(310,30, 100, 20)];
        _praiseNumLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_praiseNumLabel];
        
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
}

@end
