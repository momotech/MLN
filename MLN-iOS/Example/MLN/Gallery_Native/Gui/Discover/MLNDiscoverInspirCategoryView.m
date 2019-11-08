//
//  MLNDiscoverInspirCategoryView.m
//  MLN_Example
//
//  Created by Feng on 2019/11/7.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNDiscoverInspirCategoryView.h"

#define kDefaultBackColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]
#define kDefaultTextColor [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0]

#define kSelectedBackColor [UIColor colorWithRed:233/255.0 green:0 blue:0 alpha:1.0]
#define kSelectedTextColor [UIColor whiteColor]

@interface MLNDiscoverInspirCategoryView()

@property (nonatomic, strong) NSMutableArray *categoryButtons;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, assign) NSInteger currentSelectIndex;

@end

@implementation MLNDiscoverInspirCategoryView

- (void)reloadWithData:(NSArray *)data
{
    _dataList = data;
    
    [self reCreateCategoryButtons];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSInteger i = 0; i < self.categoryButtons.count; i++) {
        UIButton *button = self.categoryButtons[i];
        CGFloat buttonW = 40;
        CGFloat buttonH = 20;
        CGFloat buttonX = (buttonW + 5) * i;
        CGFloat buttonY = (self.bounds.size.height - buttonH)/2.0;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    }
}

- (void)reCreateCategoryButtons
{
    [self.categoryButtons removeAllObjects];
    
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        UIButton *button = [self createButtonWithTitle:self.dataList[i]];
        [button setTitle:self.dataList[i] forState:UIControlStateNormal];
        [self addSubview:button];
        [self.categoryButtons addObject:button];
    }
    
    [self updateSelectedButtonState];
}


#pragma mark - Actions
- (void)categoryButtonClicked:(UIButton *)button
{
    self.currentSelectIndex =  [self.categoryButtons indexOfObject:button];
    [self updateSelectedButtonState];
}


#pragma mark - Private method

- (void)updateSelectedButtonState
{
    for (NSInteger i = 0; i < self.categoryButtons.count; i++) {
        UIButton *button = self.categoryButtons[i];
        if (self.currentSelectIndex == i) {
            [button setTitleColor:kSelectedTextColor forState:UIControlStateNormal];
            button.backgroundColor = kSelectedBackColor;
        } else {
            [button setTitleColor:kDefaultTextColor forState:UIControlStateNormal];
            button.backgroundColor = kDefaultBackColor;
        }
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = kDefaultBackColor;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:kDefaultTextColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.cornerRadius = 10;
    [button addTarget:self action:@selector(categoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSMutableArray *)categoryButtons
{
    if (!_categoryButtons) {
        _categoryButtons = [NSMutableArray array];
    }
    return _categoryButtons;
}

@end
