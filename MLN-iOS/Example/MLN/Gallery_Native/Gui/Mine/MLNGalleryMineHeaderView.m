//
//  MLNGalleryMineHeaderView.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineHeaderView.h"

@interface MLNGalleryMineHeaderView()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *locationLabel;


@end

@implementation MLNGalleryMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setupSelfView
{
    
}


#pragma mark - getter
- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
}


@end
