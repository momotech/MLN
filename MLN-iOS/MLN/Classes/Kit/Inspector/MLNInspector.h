//
//  MLNInspector.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNInspector <NSObject>

@required

- (void) execute:(id)loadModel;
@end

NS_ASSUME_NONNULL_END
