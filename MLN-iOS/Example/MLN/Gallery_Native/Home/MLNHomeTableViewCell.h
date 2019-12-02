//
//  MLNHomeTableViewCell.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHomeTableViewCell : UITableViewCell

@property (nonatomic, assign, readonly) CGFloat cellHeight;

- (void)reloadCellWithData:(NSDictionary *)dict tableType:(NSString *)tableType;
- (void)updateFollowButtonState:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
