//
//  MLNPackage.h
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLNActionItem;

NS_ASSUME_NONNULL_BEGIN

@interface MLNPackage : NSObject

@property (nonatomic, copy) NSString *bundlePath;
@property (nonatomic, copy) NSString *entryFile;
@property (nonatomic, copy) NSString *urlString;

//本地不存在进行网络加载
@property (nonatomic, assign) BOOL needDownload;

//参数传递kMLNReloadKey标记是否需要更新重新加载
@property (nonatomic, assign) BOOL needReload;

- (instancetype)initWithURLString:(NSString *)urlString;
- (instancetype)initWithActionItem:(MLNActionItem *)actionItem;
- (instancetype)initWithEntryFile:(NSString *)entryFile bundlePath:(nullable NSString *)bundlePath;

@end

NS_ASSUME_NONNULL_END
