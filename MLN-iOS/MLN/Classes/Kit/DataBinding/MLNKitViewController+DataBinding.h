//
//  MLNKitViewController+DataBinding.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNKitViewController.h"
#import "MLNKVOObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNKitViewController (DataBinding)<MLNDataBindingProtocol>

@end

@class MLNDataBinding;
@interface MLNKitViewController () {
    MLNDataBinding *_dataBinding;
}
@end

NS_ASSUME_NONNULL_END
