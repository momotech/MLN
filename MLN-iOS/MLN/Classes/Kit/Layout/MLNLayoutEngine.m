//
//  MLNLayoutEngine.m
//
//
//  Created by MoMo on 2018/10/24.
//

#import "MLNLayoutEngine.h"
#import "MLNLayoutContainerNode.h"
#import "MLNMainRunLoopObserver.h"
#import "MLNSizeCahceManager.h"

#define kMLNRunLoopBeforeWaitingLayoutOrder 0 // befor CATransaction(2000000)

@interface MLNLayoutEngine ()
{
    MLNSizeCahceManager *_sizeCacheManager;
}
@property (nonatomic, strong) NSMutableArray<MLNLayoutContainerNode *> *rootNodesPool;
@property (nonatomic, strong) MLNMainRunLoopObserver *mainLoopObserver;

@end
@implementation MLNLayoutEngine

- (instancetype)initWithLuaInstance:(MLNKitInstance *)luaInstance
{
    if (self = [super init]) {
        _luaInstance = luaInstance;
    }
    return self;
}

- (void)start
{
    if (!self.mainLoopObserver) {
        self.mainLoopObserver = [[MLNMainRunLoopObserver alloc] init];
        [self.mainLoopObserver beginForBeforeWaiting:kMLNRunLoopBeforeWaitingLayoutOrder repeats:YES callback:^{
            [self requestLayout];
        }];
    }
}

- (void)end
{
    [self.mainLoopObserver end];
}

- (void)addRootnode:(MLNLayoutContainerNode *)rootnode
{
    if (rootnode.isRoot && ![self.rootNodesPool containsObject:rootnode]) {
        [self.rootNodesPool addObject:rootnode];
    }
}

- (void)removeRootNode:(MLNLayoutContainerNode *)rootnode
{
    if (rootnode.isRoot && [self.rootNodesPool containsObject:rootnode]) {
        [self.rootNodesPool removeObject:rootnode];
    }
}

- (void)requestLayout
{
    NSArray<MLNLayoutContainerNode *> *roots = [self.rootNodesPool copy];
    for (MLNLayoutContainerNode *rootnode in roots) {
        if (rootnode.isDirty) {
            [rootnode requestLayout];
        }
    }
}

#pragma mark - Getter
- (NSMutableArray<MLNLayoutContainerNode *> *)rootNodesPool
{
    if (!_rootNodesPool) {
        _rootNodesPool = [NSMutableArray array];
    }
    return _rootNodesPool;
}

- (MLNSizeCahceManager *)sizeCacheManager
{
    if (!_sizeCacheManager) {
        _sizeCacheManager = [[MLNSizeCahceManager alloc] initWithInstance:self.luaInstance];
    }
    return _sizeCacheManager;
}

@end
