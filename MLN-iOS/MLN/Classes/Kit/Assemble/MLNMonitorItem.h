//
//  MLNMonitorItem.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNMonitorItem : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *url64;

@property (nonatomic, copy) NSString *versionNumber;

@property (nonatomic, copy) NSString *version;

@property (nonatomic, copy) NSString *entryFile;

@property (nonatomic, copy) NSString *bundlePath;

@property (nonatomic, copy) NSString *fileFullPath;

/// isLoadRequest 默认为 NO  离线包类型，1：远端  2:解压 3：离线
/// isLoadRequest 为 YES 时,  离线包类型，0：预埋  1:离线 2：远端
@property (nonatomic, assign) NSUInteger sourceType;

@property (nonatomic, assign) BOOL isLoadRequest;

@property (nonatomic, copy) NSString *luaCore;

@end

NS_ASSUME_NONNULL_END
