//
//  MLNUIBundle.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUILuaBundle.h"
#import "MLNUIHeader.h"

@interface MLNUILuaBundle ()

@property (nonatomic, strong) NSBundle *currentBundle;
@property (nonatomic, strong) NSBundle *systemBundle;
#if Argo_Debug_Check_Pre_Require
@property (nonatomic, strong) NSMutableArray *needPreRequireFiles;
#endif
@end

@implementation MLNUILuaBundle

+ (instancetype)mainBundle
{
    return [[self alloc] initWithBundle:[NSBundle mainBundle]];
}

+ (instancetype)mainBundleWithPath:(NSString *)path
{
    NSString *bundlePath = [[[NSBundle  mainBundle] bundlePath] stringByAppendingPathComponent:path];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [[self alloc] initWithBundle:bundle];
}

+ (instancetype)bundleLibraryWithPath:(NSString *)path
{
    NSString *libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *bundlePath = [libraryDir stringByAppendingPathComponent:path];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [[self alloc] initWithBundle:bundle];
}

+ (instancetype)bundleDocumentsWithPath:(NSString *)path
{
    return [self bundleWithPath:path directory:NSDocumentDirectory];
}

+ (instancetype)bundleCachesWithPath:(NSString *)path
{
    return [self bundleWithPath:path directory:NSCachesDirectory];
}

+ (instancetype)bundleWithPath:(NSString *)path directory:(NSSearchPathDirectory)directory
{
    NSString *directorypPath = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) firstObject];
    NSString *bundlePath = [directorypPath stringByAppendingPathComponent:path];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [[self alloc] initWithBundle:bundle];;
}

- (instancetype)initWithBundlePath:(NSString *)bundlePath
{
    return [self initWithBundle:[NSBundle bundleWithPath:bundlePath]];
}

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        _currentBundle = bundle;
        _systemBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ArgoUISystem" ofType:@"bundle"]];
#if Argo_Debug_Check_Pre_Require
        _needPreRequireFiles = [NSMutableArray array];
        NSBundle *bundle = _systemBundle;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSDirectoryEnumerator *fileEnumerator =
        [fileManager enumeratorAtURL:bundle.bundleURL
                  includingPropertiesForKeys:nil
                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                        errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
               NSLog(@"error %@ url %@",error, url);
               return NO;
        }];
        for (NSURL *fileURL in fileEnumerator) {
            NSString *urlPath = [fileURL path];
            if ([urlPath hasSuffix:@".lua"]) {
                urlPath = [urlPath stringByDeletingPathExtension];
                NSRange range = [urlPath rangeOfString:@"ArgoUISystem.bundle"];
                if (range.location != NSNotFound && urlPath.length > range.location + range.length) {
                    NSString *requireName = [urlPath substringFromIndex:range.location + range.length + 1];
//                    requireName = [requireName stringByReplacingOccurrencesOfString:@".lua" withString:@""];
//                    [luaCore requireLuaFile:requireName.UTF8String];
                    if (requireName) {
                        [self.needPreRequireFiles addObject:requireName];
                    }
                }
            }
        }
#endif
    }
    return self;
}

- (NSString *)filePathWithName:(NSString *)name
{
    NSString *filePath;
    if (name) {
        filePath = [self.currentBundle pathForResource:name ofType:nil];
        if (!filePath) {
            filePath = [self.currentBundle pathForResource:name ofType:@"lua"];
        }
        if (!filePath) {// hotreload 新建文件出错 not found ... 
            filePath = [self.currentBundle pathForResource:name ofType:nil inDirectory:@"/"];
        }
        // 如果业务bundle中的lua文件在system bundle中也存在，说明没有预加载，提示升级SDK
#if Argo_Debug_Check_Pre_Require
        if (filePath) {
            NSString *fileName = [name stringByReplacingOccurrencesOfString:@".lua" withString:@""];
            if (fileName && [self.needPreRequireFiles containsObject:fileName]) {
                NSLog(@"%@ 没有使用预加载文件，请确认是否已将ArgoUI升级到最新版本.", filePath);
            }
        }
#endif
        if (!filePath) {
            filePath = [self.systemBundle pathForResource:name ofType:nil];
        }
        if (!filePath) {
            filePath = [self.systemBundle pathForResource:name ofType:@"lua"];
        }
    }
    return filePath;
}

- (NSString *)bundlePath
{
    return self.currentBundle.bundlePath;
}

@end
