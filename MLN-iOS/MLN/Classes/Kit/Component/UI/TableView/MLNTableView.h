//
//  MMTableView.h
//  MLN
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNTableViewAdapterProtocol.h"
#import "MLNScrollCallbackView.h"
@class MLNInnerTableView;

@interface MLNTableView : MLNScrollCallbackView <MLNEntityExportProtocol>

@property (nonatomic, weak) id<MLNTableViewAdapterProtocol> adapter;

@property (nonatomic, strong, readonly) MLNInnerTableView *innerTableView;

@end
