//
//  MLNUIInnerTableView.h
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUILuaCore;
@interface MLNUIInnerTableView : UITableView

@property (nonatomic, weak) id<MLNUIEntityExportProtocol> containerView;

- (MLNUILuaCore *)mlnui_luaCore;

@end

NS_ASSUME_NONNULL_END
