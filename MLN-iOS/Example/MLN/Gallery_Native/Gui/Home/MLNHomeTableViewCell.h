//
//  MLNHomeTableViewCell.h
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHomeTableViewCell : UITableViewCell

@property (nonatomic, assign, readonly) CGFloat cellHeight;

- (void)reloadCellWithData:(NSDictionary *)dict;
- (void)updateFollowButtonState:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
