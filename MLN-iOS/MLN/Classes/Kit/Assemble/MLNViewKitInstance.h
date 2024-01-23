//
//  MLNViewKitInstance.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/10.
//

#import "MLNKitInstance.h"
@class MLNViewController;

NS_ASSUME_NONNULL_BEGIN

@interface MLNViewKitInstance : MLNKitInstance
@property (nonatomic, strong) MLNViewController *innerController;
@end

NS_ASSUME_NONNULL_END
