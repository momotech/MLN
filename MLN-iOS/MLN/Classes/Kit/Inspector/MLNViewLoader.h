//
//  MLNViewLoader.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import <Foundation/Foundation.h>
#import "MLNViewInspectorManager.h"
@class MLNViewLoadModel;
@protocol MLNInspector,MLNKitInstanceErrorHandlerProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface MLNViewLoader : NSObject

@property(nonatomic, strong) MLNViewInspectorManager *inspectorManager;

- (void)loadView:(MLNViewLoadModel *) loadModel;

@end

NS_ASSUME_NONNULL_END
