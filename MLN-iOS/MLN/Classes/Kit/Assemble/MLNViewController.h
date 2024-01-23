//
//  MLNViewController.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/10.
//

//#import <MDUIBaseKit/MDUIBaseKit.h>
@import UIKit;

@protocol MLNViewControllerProtocol;
@class MLNKitInstance;

NS_ASSUME_NONNULL_BEGIN

@interface MLNViewController : UIViewController <MLNViewControllerProtocol>
@property (nonatomic, weak) MLNKitInstance *luaInstance;

@end

NS_ASSUME_NONNULL_END
