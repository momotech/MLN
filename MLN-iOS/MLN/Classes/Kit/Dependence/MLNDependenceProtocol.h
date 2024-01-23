//
//  MLNDependenceProtocol.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNDependenceErrorDelegate <NSObject>

@optional
-(void)mlnDependenceErrorWithProjectTag:(NSString *)pTag
                              withGroup:(NSString *) gid
                   withWidget:(NSString *) wid
                    withError:(NSError *) error;

@end

@protocol MLNDependenceCacheDelegate <NSObject>

@optional
-(void)updatePathWith:(NSString *) wid withPath:(NSString *) path;

-(void)removePathWith:(NSString *) wid;

-(NSString *)queryPathWith:(NSString *) wid;

@end

@protocol MLNDependenceZipDelegate <NSObject>

@required
-(BOOL)findZipWithGourp:(NSString *)groupName
         withIdentifier:(NSString *) identifier
            withVersion:(NSString *) version;
-(void)unzipWithGourp:(NSString *)groupName
       withIdentifier:(NSString *) identifier
          withVersion:(NSString *) version withFinish:(void(^)(BOOL)) finished;
-(BOOL)removeZipWithGourp:(NSString *)groupName
           withIdentifier:(NSString *) identifier
              withVersion:(NSString *) version;

@end

@protocol MLNDependenceDownloadDelegate <NSObject>

@required
-(void)downloadSourceWithGourp:(NSString *)groupName
                withIdentifier:(NSString *) identifier
                   withVersion:(NSString *) version
                    withFinish:(void(^)(BOOL)) finished;

@end

@protocol MLNDependenceGroupFileDelegate <NSObject>

@required
-(BOOL)removeGroupFileWith:(NSString *)groupName
            withIdentifier:(NSString *) identifier
               withVersion:(NSString *) version;
-(NSString *)findGroupPathFileWith:(NSString *)groupName
                    withIdentifier:(NSString *) identifier
                       withVersion:(NSString *) version;

@end

@protocol MLNDependenceProtocol <MLNDependenceCacheDelegate,
                                MLNDependenceZipDelegate,
                                MLNDependenceDownloadDelegate,
                                MLNDependenceGroupFileDelegate>

@end

NS_ASSUME_NONNULL_END
