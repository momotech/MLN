//
//  MLNDependenceModel.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import <Foundation/Foundation.h>
#import "MLNDependenceGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNDependenceModel : NSObject

/// MLN project 依赖的 group
@property (nonatomic, strong) NSArray<MLNDependenceGroup *> *group;

-(void)transfromDicToModel:(NSDictionary *) sourceDic;

@end

NS_ASSUME_NONNULL_END
