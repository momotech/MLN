//
//  MMTableViewAdpater.h
//  MLNUI
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNUIScrollViewDelegate.h"
#import "MLNUIEntityExportProtocol.h"
#import "MLNUITableViewAdapterProtocol.h"
#import "MLNUIAdapterCachesManager.h"

@class MLNUIBlock, MLNUITableView;
@interface MLNUITableViewAdapter : MLNUIScrollViewDelegate <UITableViewDataSource, MLNUIEntityExportProtocol, MLNUITableViewAdapterProtocol>

@property (nonatomic, weak) UITableView *targetTableView;
@property (nonatomic, weak) MLNUITableView *mlnuiTableView;
@property (nonatomic, strong, readonly) Class tableViewCellClass;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *initedCellCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *fillCellDataCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNUIBlock *> *heightForRowCallbacks;

// caches
@property (nonatomic, strong, readonly) MLNUIAdapterCachesManager *cachesManager;

- (NSString *)reuseIdAt:(NSIndexPath *)indexPath;
- (MLNUIBlock *)initedCellCallbackByReuseId:(NSString *)reuseId;
- (MLNUIBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId;

@end
