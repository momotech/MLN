//
//  MLNListDetectItem.h
//  MLN
//
//  Created by xue.yunqiang on 2022/3/2.
//

#import <Foundation/Foundation.h>
#import "MLNListWhiteDetectLogProtocol.h"
#import "MLNKitInstance.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNListDetectItem : NSObject

@property (nonatomic, assign) NSInteger detectTimeLimite;

@property (nonatomic, assign) NSInteger detectTimeInterval;

@property (nonatomic, assign) NSInteger detectLayerDeep;

@property (nonatomic, assign) NSInteger detectLayerBreadth;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) id<MLNListWhiteDetectLogProtocol> logHandle;

@property (nonatomic, weak) MLNKitInstance *instance;

@end

NS_ASSUME_NONNULL_END
