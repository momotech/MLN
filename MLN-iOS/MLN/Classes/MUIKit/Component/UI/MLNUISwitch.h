//
//  MLNUISwitch.h
//
//
//  Created by MoMo on 2018/12/18.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUIBlock;
@interface MLNUISwitch : UISwitch<MLNUIEntityExportProtocol>

@property (nonatomic, strong) MLNUIBlock *switchChangedCallback;

@end

NS_ASSUME_NONNULL_END
