//
//  MLNDependenceTaskManager.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/10.
//

#import <Foundation/Foundation.h>
#import "MLNDependenceGroup.h"
#import "MLNDependenceWidget.h"
@protocol MLNDependenceProtocol;
@class MLNDependenceModel;

typedef void (^MLNDependenceWidgetTask)(BOOL);

NS_ASSUME_NONNULL_BEGIN

@interface MLNDependenceTaskManager : NSObject

@property(nonatomic, strong) id<MLNDependenceProtocol> delegate;

+ (instancetype)shareManager;

-(void)unzipWithGourp:(MLNDependenceGroup *)group withFinish:(void(^)(BOOL)) finished;

-(void)downloadWithGourp:(MLNDependenceGroup *)group finished:(void(^)(BOOL)) finished;

-(BOOL)findedGroupPathWithGroup:(MLNDependenceGroup *)group;

-(BOOL)findZipWithGourp:(MLNDependenceGroup *)group;

-(BOOL)removeGroupFileGourp:(MLNDependenceGroup *)group;

- (MLNDependenceModel *)transfromDependenceModel:(NSDictionary *)dependenceDesDic;

/// 提前下载并解压工程的依赖文件
/// @param dependenceConfigPath 依赖文件位置
- (void)projectPrePareDependenceWithConfigPath:(NSString *) dependenceConfigPath;

@end

NS_ASSUME_NONNULL_END
