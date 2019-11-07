//
//  MLNGalleryNavigatorView.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryNavigationBar.h"
#import "UIImage+MLNResize.h"

#define kMLNNavigatorBGColor ([UIColor whiteColor])
#define kMLNNavigatorFontSize 15

@implementation MLNGalleryNavigationBarItem

@end

@interface MLNGalleryNavigationBar()

@property (nonatomic, strong) UIButton *numberButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) MLNGalleryNavigationBarItem *leftItem;
@property (nonatomic, strong) NSArray <MLNGalleryNavigationBarItem *> *rightItems;
@property (nonatomic, strong) NSMutableArray *mRightButtons;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

static NSInteger const buttonTag = 10;

@implementation MLNGalleryNavigationBar


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _mRightButtons = [NSMutableArray array];
        self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.titleView.bounds];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textColor = [UIColor colorWithRed:50 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return self;
}

- (void)setLeftItem:(MLNGalleryNavigationBarItem *)leftItem
{
    if (!leftItem.image) {
        leftItem.image = [UIImage imageNamed:@"UIBundle.bundle/nav_back_bg1"];
    }
    _leftItem = leftItem;
    if (leftItem) {
        [self.leftButton setImage:leftItem.image forState:UIControlStateNormal];
        self.leftButton.hidden = NO;
    } else {
        _leftButton.hidden = YES;
    }
}

- (void)setRightItem:(MLNGalleryNavigationBarItem *)rightItem
{
    if (rightItem) {
        [self setRightItems:@[rightItem]];
    } else {
        [self setRightItems:nil];
    }
}

- (void)setRightItems:(NSArray <MLNGalleryNavigationBarItem *> *)rightItems
{
    _rightItems = [rightItems copy];
    NSInteger count = rightItems.count;
    [self removeRightBtnsFromSuperView];
    [rightItems enumerateObjectsUsingBlock:^(MLNGalleryNavigationBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *button = nil;
        if (_mRightButtons.count > idx) {
            button = [_mRightButtons objectAtIndex:idx];
        }
        if (!button) {
            button = [[UIButton alloc] init];
            button.adjustsImageWhenHighlighted = NO;
            [button addTarget:self action:@selector(rightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            if (button) {
                [_mRightButtons addObject:button];
            }
        }
        [button setImage:obj.image forState:UIControlStateNormal];
        button.tag = idx + buttonTag;
        CGFloat buttonW = 30.f;
        CGFloat buttonX = [UIScreen mainScreen].bounds.size.width - (count-idx) * (buttonW + 15);
        CGFloat buttonY =  self.frame.size.height - buttonW - 7;
        CGRect frame = CGRectMake(buttonX, buttonY, buttonW, buttonW);
        button.frame = frame;
        [self addSubview:button];
    }];
}

- (void)setTitleView:(UIView *)titleView
{
    if (_titleView) {
        [_titleView removeFromSuperview];
        _titleView = nil;
    }
    _titleView = titleView;
    CGPoint center  = titleView.center;
    center.x = self.frame.size.width * 0.5;
    titleView.center = center;
    CGRect frame = titleView.frame;
    frame.origin.y = self.frame.size.height - titleView.frame.size.height;
    titleView.frame = frame;
    [self addSubview:titleView];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setMsgNumber:(NSInteger)count
{
    if (count > 0) {
        self.numberButton.hidden = NO;
        [self.numberButton setTitle:[NSString stringWithFormat:@"%zd", count] forState:UIControlStateNormal];
        [self.numberButton sizeToFit];
        CGRect frame  = self.numberButton.frame;
        if (count < 10) {
            frame.size.width = 22.f;
        } else {
            frame.size.width += 8.f;
        }
        //        self.numberButton.width += 13.f;
        frame.size.height = 22.f;
        frame.origin.x = CGRectGetMaxX(_leftButton.frame)-10;
        frame.origin.x = self.frame.size.height-frame.size.height-11.f;
        self.numberButton.frame = frame;
    } else {
        self.numberButton.hidden = YES;
    }
}

#pragma mark - 辅助方法
- (void)removeRightBtnsFromSuperView
{
    [_mRightButtons enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

#pragma mark - 点击事件
- (void)leftButtonClickAction:(UIButton *)sender
{
    if (self.leftItem && self.leftItem.clickActionBlock) {
        self.leftItem.clickActionBlock();
    }
}

- (void)rightButtonClickAction:(UIButton *)sender
{
    NSInteger index = sender.tag - buttonTag;
    MLNGalleryNavigationBarItem *item = [_rightItems objectAtIndex:index];
    if (item && item.clickActionBlock) {
        item.clickActionBlock();
    }
}

#pragma mark - lazy load
- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)];
        CGPoint center = _leftButton.center;
        center.y = self.frame.size.height*0.5;
        _leftButton.center = center;
        _leftButton.adjustsImageWhenHighlighted = NO;
        [_leftButton addTarget:self action:@selector(leftButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
    }
    return _leftButton;
}

- (UIButton *)numberButton
{
    if (!_numberButton) {
        _numberButton = [[UIButton alloc] init];
        
        UIImage *bgImage = [[UIImage imageWithColor:[UIColor colorWithRed:248/255.0 green:85/255.0 blue:67/255.0 alpha:1.0] finalSize:CGSizeMake(24, 22) cornerRadius:11] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 11) resizingMode:UIImageResizingModeStretch];
        _numberButton.userInteractionEnabled = NO;
        [_numberButton setBackgroundImage:bgImage forState:UIControlStateNormal];
        [_numberButton setAdjustsImageWhenHighlighted:NO];
        
        _numberButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_numberButton];
    }
    return _numberButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _leftButton.frame = CGRectMake(5, self.frame.size.height-44, 44, 44);
    
}

- (UILabel *)defaultTitleLabel
{
    return self.titleLabel;
}

- (UIButton *)rightButtonAtIndex:(NSInteger)index{
    if (index< _mRightButtons.count) {
        return _mRightButtons[index];
    }
    return nil;
}

@end
