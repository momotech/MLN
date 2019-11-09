//
//  MLNDiscoverTagView.h
//  MLN_Example
//
//  Created by Feng on 2019/11/8.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDiscoverTagView : UIView

@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *selectedBackgrundColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, assign) BOOL selectEnable;


- (void)reloadWithDataList:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
