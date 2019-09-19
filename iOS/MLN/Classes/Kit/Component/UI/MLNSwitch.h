//
//  MLNSwitch.h
//
//
//  Created by MoMo on 2018/12/18.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNBlock;
@interface MLNSwitch : UISwitch<MLNEntityExportProtocol>

@property (nonatomic, strong) MLNBlock *switchChangedCallback;

@end

NS_ASSUME_NONNULL_END
