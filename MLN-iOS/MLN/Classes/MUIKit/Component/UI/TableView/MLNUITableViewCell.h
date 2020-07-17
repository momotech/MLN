//
//  MMTableViewCell.h
//  MLNUI
//
//  Created by MoMo on 28/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNUIReuseContentView.h"
#import "MLNUITableViewCellSettingProtocol.h"
#import "MLNUITableViewAdapterProtocol.h"

#define kMLNUITableViewCellReuseID @"kMLNUITableViewCellReuseID"

@class MLNUITableViewCell;
@protocol MLNUITableViewCellDelegate <NSObject>

@optional
/// cell上的内容大小发生变更时回调
- (void)mlnuiTableViewCellShouldReload:(MLNUITableViewCell *)cell;

@end

@interface MLNUITableViewCell : UITableViewCell <MLNUIReuseCellProtocol>

@property (nonatomic, strong) MLNUIReuseContentView *luaContentView;
@property (nonatomic, weak) id<MLNUITableViewCellSettingProtocol, MLNUITableViewCellDelegate> delegate;

- (void)updateSubviewsFrameIfNeed;

@end
