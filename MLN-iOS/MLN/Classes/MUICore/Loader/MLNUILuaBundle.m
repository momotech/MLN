//
//  MLNUIBundle.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUILuaBundle.h"

@interface MLNUILuaBundle ()

@property (nonatomic, strong) NSBundle *currentBundle;
@property (nonatomic, strong) NSBundle *systemBundle;
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
