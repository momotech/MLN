//
//  MLNDiscoverTagView.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNDiscoverTagView.h"

#define kDefaultBackColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]
#define kDefaultTextColor [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0]

#define kSelectedBackColor [UIColor colorWithRed:233/255.0 green:0 blue:0 alpha:1.0]
#define kSelectedTextColor [UIColor whiteColor]

@interface MLNDiscoverTagView()

@property (nonatomic, strong) NSMutableArray *tagButtons;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation MLNDiscoverTagView

- (void)reloadWithDataList:(NSArray *)dataList
{
    _dataList = dataList;
    
    [self reCreateCategoryButtons];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat startX = 0;
    for (NSInteger i = 0; i < self.tagButtons.count; i++) {
        UIButton *button = self.tagButtons[i];
        CGFloat buttonW = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 10;
        CGFloat buttonH = 20;
        CGFloat buttonX = startX;
        CGFloat buttonY = (self.bounds.size.height - buttonH)/2.0;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        startX = startX + buttonW + 10;
    }
}

- (void)reCreateCategoryButtons
{
    [self.tagButtons makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    [self.tagButtons removeAllObjects];
    
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        UIButton *button = [self createButtonWithTitle:self.dataList[i]];
        [button setTitle:self.dataList[i] forState:UIControlStateNormal];
        [self addSubview:button];
        [self.tagButtons addObject:button];
    }
    
    [self updateSelectedButtonState];
}


#pragma mark - Actions
- (void)categoryButtonClicked:(UIButton *)button
{
    self.selectedIndex =  [self.tagButtons indexOfObject:button];
    [self updateSelectedButtonState];
}


#pragma mark - Private method

- (void)updateSelectedButtonState
{
    for (NSInteger i = 0; i < self.tagButtons.count; i++) {
        UIButton *button = self.tagButtons[i];
        if (self.selectedIndex == i && self.selectEnable) {
            [button setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            button.backgroundColor = self.selectedBackgrundColor;
        } else {
            [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
            button.backgroundColor = self.normalBackgroundColor;
        }
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = self.normalBackgroundColor ?: kDefaultBackColor;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    UIColor *titleColor = self.normalTextColor ?: kDefaultTextColor;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(categoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSMutableArray *)tagButtons
{
    if (!_tagButtons) {
        _tagButtons = [NSMutableArray array];
    }
    return _tagButtons;
}


@end
