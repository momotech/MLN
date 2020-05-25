//
//  MLNUILayoutEngine.m
//
//
//  Created by MoMo on 2018/10/24.
//

#import "MLNUILayoutEngine.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUIMainRunLoopObserver.h"
#import "MLNUISizeCahceManager.h"

#define kMLNUIRunLoopBeforeWaitingLayoutOrder 0 // befor CATransaction(2000000)

@interface MLNUILayoutEngine ()
{
    MLNUISizeCahceManager *_sizeCacheManager;
}
@property (nonatomic, strong) NSMutableArray<MLNUILayoutContainerNode *> *rootNodesPool;
@property (nonatomic, strong) MLNUIMainRunLoopObserver *mainLoopObserver;

@end
@implementation MLNUILayoutEngine

- (instancetype)initWithLuaInstance:(MLNUIKitInstance *)luaInstance
{
    if (self = [super init]) {
        _luaInstance = luaInstance;
    }
    return self;
}

- (void)start
{
    if (!self.mainLoopObserver) {
        self.mainLoopObserver = [[MLNUIMainRunLoopObserver alloc] init];
        [self.mainLoopObserver beginForBeforeWaiting:kMLNUIRunLoopBeforeWaitingLayoutOrder repeats:YES callback:^{
            [self requestLayout];
        }];
    }
}

- (void)end
{
    [self.mainLoopObserver end];
}

- (void)addRootnode:(MLNUILayoutContainerNode *)rootnode
{
    if (rootnode.isRoot && ![self.rootNodesPool containsObject:rootnode]) {
        [self.rootNodesPool addObject:rootnode];
    }
}

- (void)removeRootNode:(MLNUILayoutContainerNode *)rootnode
{
    if (rootnode.isRoot && [self.rootNodesPool containsObject:rootnode]) {
        [self.rootNodesPool removeObject:rootnode];
    }
}

- (void)requestLayout
{
    NSArray<MLNUILayoutContainerNode *> *roots = [self.rootNodesPool copy];
    for (MLNUILayoutContainerNode *rootnode in roots) {
        if (rootnode.isDirty) {
            [rootnode requestLayout];
        }
    }
}

#pragma mark - Getter
- (NSMutableArray<MLNUILayoutContainerNode *> *)rootNodesPool
{
    if (!_rootNodesPool) {
        _rootNodesPool = [NSMutableArray array];
    }
    return _rootNodesPool;
}

- (MLNUISizeCahceManager *)sizeCacheManager
{
    if (!_sizeCacheManager) {
        _sizeCacheManager = [[MLNUISizeCahceManager alloc] initWithInstance:self.luaInstance];
    }
    return _sizeCacheManager;
}

@end
