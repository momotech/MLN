//
//  MLNUserDowngradeProtol.h
//  MLN
//
//  Created by xue.yunqiang on 2022/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNUserDowngradeProtol <NSObject>

@optional
-(void)downgradeIgnoreLoading:(BOOL) ignore;

@end

NS_ASSUME_NONNULL_END
