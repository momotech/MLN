//
//  MMTableViewCell.h
//  MLN
//
//  Created by MoMo on 28/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNReuseContentView.h"
#import "MLNTableViewCellSettingProtocol.h"
#import "MLNTableViewAdapterProtocol.h"

#define kMLNTableViewCellReuseID @"kMLNTableViewCellReuseID"

@interface MLNTableViewCell : UITableViewCell <MLNReuseCellProtocol>

@property (nonatomic, strong) MLNReuseContentView *luaContentView;
@property (nonatomic, weak) id<MLNTableViewCellSettingProtocol> delegate;

- (void)updateSubviewsFrameIfNeed;

@end
