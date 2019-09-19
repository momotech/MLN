//
//  MMTableViewAdpater.h
//  MomoChat
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNScrollViewDelegate.h"
#import "MLNEntityExportProtocol.h"
#import "MLNTableViewAdapterProtocol.h"
#import "MLNAdapterCachesManager.h"

@class MLNBlock;
@interface MLNTableViewAdapter : MLNScrollViewDelegate <UITableViewDataSource, MLNEntityExportProtocol, MLNTableViewAdapterProtocol>

@property (nonatomic, weak) UITableView *targetTableView;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNBlock *> *initedCellCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNBlock *> *fillCellDataCallbacks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MLNBlock *> *heightForRowCallbacks;

// caches
@property (nonatomic, strong, readonly) MLNAdapterCachesManager *cachesManager;

- (NSString *)reuseIdAt:(NSIndexPath *)indexPath;
- (MLNBlock *)initedCellCallbackByReuseId:(NSString *)reuseId;
- (MLNBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId;

@end
