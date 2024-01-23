//
//  MLNViewLoadModel.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import <Foundation/Foundation.h>
#import "MLNLuaView.h"
#import "MLNViewLoader.h"
#import "MLNConvertorProtocol.h"
#import "MLNLuaViewLogUploadProtocol.h"
#import "MLNLoadPipelineProtocol.h"
#import "MLNKitInstanceDelegate.h"
#import "MLNListDetectItem.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MLNLuaViewErrorLayoutInfo = 2000, // By default
    MLNLuaViewErrorLoadWindow,
    MLNLuaViewErrorFilePath,
    MLNLuaViewErrorRegitClass,
    MLNLuaViewErrorRunCode,
} MLNLuaViewError;


@interface MLNViewLoadModel : NSObject

//loader
@property (nonatomic, weak) MLNViewLoader *loader;

//basic
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) NSString *enterFilePath;
@property (nonatomic, copy) NSString *fullEnterFilePath;
@property (nonatomic, copy) NSString *srcFilePath;
@property (nonatomic, copy) NSString *identfier;
@property (nonatomic, copy) NSString *resourceId;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *url64;
@property (nonatomic, copy, nullable) NSString *bundle;
@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, copy, nullable) NSString *fileFullPath;
@property (nonatomic, copy) NSString *business;

@property (nonatomic, strong) MLNLuaView *luaView;
@property (nonatomic, assign) int forceLocal;
@property (nonatomic, assign) int newest;

//bridge refrence
@property (nonatomic, strong) NSArray<Class<MLNExportProtocol>> *suppleLuaBridgeClasses;
//converte struct
@property (nonatomic, strong) Class<MLNConvertorProtocol> convertorClass;

//layout
@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) MLNLuaViewWindowLayoutStrategy layoutStrategy;
@property (nonatomic, assign) MLNLayoutMeasurementType heightLayoutStrategy;
@property (nonatomic, assign) MLNLayoutMeasurementType widthLayoutStrategy;
@property (nonatomic, strong) NSMutableDictionary *windowExtro;

//error
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, assign) BOOL loadError;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, strong) id<MLNLuaViewErrorViewProtocol> errorViewBuilder;
@property (nonatomic, strong) id<MLNLuaViewLogUploadProtocol> logUploader;
@property (nonatomic, strong) id <MLNInspector,MLNKitInstanceErrorHandlerProtocol> errorCatchInspector;
@property (nonatomic, strong) id <MLNLoadPipelineProtocol> pipelineHandle;
@property (nonatomic, strong) id<MLNDependenceProtocol> dependenceHandle;
@property (nonatomic, strong) id<MLNKitInstanceDelegate> instanceHandle;

- (NSDictionary *)basicInfo;

//list detect
@property (nonatomic, strong) MLNListDetectItem *detectItem;

@end

NS_ASSUME_NONNULL_END
