//
//  MLNLuaViewErrorViewProtocol.h
//  MLN
//
//  Created by xue.yunqiang on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import "MLNViewLoadModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MLNLuaViewErrorViewProtocol <NSObject>
@required
- (UIView *)errorView:(MLNViewLoadModel *)loadModel;

@end

NS_ASSUME_NONNULL_END
