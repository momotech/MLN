//
//  MLNDiscoverTagView.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
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
