//
//  MMTableView.h
//  MLNUI
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"
#import "MLNUITableViewAdapterProtocol.h"
#import "MLNUIScrollCallbackView.h"

@interface MLNUITableView : MLNUIScrollCallbackView <MLNUIEntityExportProtocol>

@property (nonatomic, weak) id<MLNUITableViewAdapterProtocol> adapter;

@end
