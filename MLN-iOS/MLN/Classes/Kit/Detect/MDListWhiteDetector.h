//
//  MDListWhiteDetector.h
//  MLN
//
//  Created by xue.yunqiang on 2022/3/2.
//

#import <Foundation/Foundation.h>
@class MLNListDetectItem, MLNLayoutNode;

NS_ASSUME_NONNULL_BEGIN

@interface MDListWhiteDetector : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDetectItem:(MLNListDetectItem *) item NS_DESIGNATED_INITIALIZER;

- (void)start:(MLNLayoutNode *)node;

- (void)stop;

- (void)reload;



@end

NS_ASSUME_NONNULL_END
