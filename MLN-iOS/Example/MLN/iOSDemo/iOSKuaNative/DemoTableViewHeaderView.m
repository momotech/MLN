//
//  DemoTableViewHeaderCell.m
//  LuaNative
//
//  Created by MOMO on 2020/9/4.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <SDWebImage/SDWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import <Masonry/Masonry.h>
#import "DemoTableViewHeaderView.h"
//#import "DemoFirstViewController.h"



@implementation DemoTableViewHeaderView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *icon_img = [UIImageView new];
//        [icon_img sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/custom/ios/icon_feng.png"]
//                    placeholderImage:[UIImage imageNamed:@"icon_feng.png"]];
        [icon_img sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/custom/ios/icon_feng.png"]];
        [self addSubview:icon_img];
        
        UILabel *nameLabel = [self tagLabelWithText:@"马铃薯爱吃土豆泥" textColor:nil];
        [self addSubview:nameLabel];
        
        UILabel *signatureLabel = [self tagLabelWithText:@"2天前.来自通讯录不要动我的土豆泥" textColor:UIColor.grayColor];
        signatureLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:signatureLabel];
        
        UILabel *addFriend = [self tagLabelWithText:@"+好友" textColor:UIColor.greenColor];
        addFriend.font = [UIFont systemFontOfSize:13];
        [self addSubview:addFriend];
        
        UILabel *content_txt = [self tagLabelWithText:@"蜜蜂福利时间到~" textColor:nil];
        content_txt.font = [UIFont systemFontOfSize:16];
        [self addSubview:content_txt];
        
        UILabel *content_tag = [UILabel new];
        content_tag.text = @"#李易峰新综艺#李易峰Boss衬衫";
        content_tag.textColor = UIColor.blueColor;
        content_tag.font = [UIFont systemFontOfSize:12];
        [self addSubview:content_tag];
        
        UIImageView *content_img = [UIImageView new];
        [content_img sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/custom/ios/liyifeng.jpg"]
                       placeholderImage:[UIImage imageNamed:@"liyifeng.jpg"]];
        [self addSubview:content_img];
        
        UIImageView *praise = [UIImageView new];
        [praise sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/custom/MLNUI/Checked.png"]
                  placeholderImage:[UIImage imageNamed:@"Checked.png"]];
        [self addSubview:praise];
        
        UILabel *praise_num = [self tagLabelWithText:@"20w+" textColor:nil];
        praise_num.font = [UIFont systemFontOfSize:14];
        [self addSubview:praise_num];
        
        UIImageView *comment = [UIImageView new];
        [comment sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/custom/ios/content.png"]
                   placeholderImage:[UIImage imageNamed:@"content.png"]];
        [self addSubview:comment];
        comment.frame = CGRectMake(0, 0, 0, 0);
        
        UILabel *comment_num = [self tagLabelWithText:@"3w+" textColor:nil];
        comment_num.font = [UIFont systemFontOfSize:14];
        [self addSubview:comment_num];
        
        UIImageView *send_img = [UIImageView new];
        [send_img sd_setImageWithURL:[NSURL URLWithString:@"https://s.momocdn.com/w/u/others/custom/ios/send_news.png"]
                    placeholderImage:[UIImage imageNamed:@"send.png"]];
        [self addSubview:send_img];
        
        UILabel *send_txt = [self tagLabelWithText:@"分享" textColor:nil];
        send_txt.font = [UIFont systemFontOfSize:14];
        [self addSubview:send_txt];
        
        [icon_img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(20);
            make.left.mas_equalTo(self.mas_left).mas_offset(20);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(70);
        }];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(25);
            make.left.mas_equalTo(icon_img.mas_right).mas_offset(15);
            make.width.mas_equalTo(150);
            make.height.mas_equalTo(30);
        }];
        
        [signatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(nameLabel.mas_top).mas_offset(20);
            make.left.mas_equalTo(icon_img.mas_right).mas_offset(15);
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(50);
        }];
        
        [addFriend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(35);
            make.left.mas_equalTo(nameLabel.mas_right).mas_offset(42);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(10);
        }];
        
        [content_txt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(icon_img.mas_bottom).mas_offset(5);
            make.left.mas_equalTo(self.mas_left).mas_offset(22);
            make.width.mas_equalTo(400);
            make.height.mas_equalTo(50);
        }];
        
        [content_tag mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_txt.mas_bottom).mas_offset(-6);
            make.left.mas_equalTo(self.mas_left).mas_offset(20);
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(20);
        }];
        
        [content_img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_tag.mas_bottom).mas_offset(5);
            make.left.mas_equalTo(self.mas_left).mas_offset(40);
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(370);
        }];
        
        [praise mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_img.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(self.mas_left).mas_offset(20);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        [praise_num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_img.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(praise.mas_right).mas_offset(5);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(20);
        }];
        
        [comment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_img.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(praise_num.mas_right).mas_offset(10);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        [comment_num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_img.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(comment.mas_right).mas_offset(5);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(20);
        }];
        
        [send_img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_img.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(comment.mas_right).mas_offset(170);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        [send_txt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content_img.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(send_img.mas_right).mas_offset(5);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-10);
            
            make.width.mas_equalTo(50);
//            make.height.mas_equalTo(20);
        }];
        
    }
    return self;
}

- (UILabel *)tagLabelWithText:(NSString *)text textColor:(UIColor *)textColor {
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = textColor ? textColor : [UIColor blackColor];
    return label;
}

@end
