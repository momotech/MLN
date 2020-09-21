//
//  ArgoObserverBase.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/26.
//

#import "ArgoObserverBase.h"
#import "MLNUIExtScope.h"

@interface ArgoObserverBase()
@property (nonatomic, copy) void(^liveBlock)(void);

@property (nonatomic, copy) ArgoViewControllerLifeCycle lifeCycleListener;
@property (nonatomic, copy, readwrite) NSString *keyPath;
@end

@implementation ArgoObserverBase

- (instancetype)initWithViewController:(UIViewController<ArgoViewControllerProtocol> *)viewController callback:(ArgoBlockChange)callback keyPath:(NSString *)keyPath {
    if (self = [super init]) {
        _viewController = viewController;
        _callback = callback;
        _keyPath = keyPath;
        _active = YES;
        [self addViewControllerObserver:viewController];
    }
    return self;
}

- (void)addViewControllerObserver:(UIViewController *)viewController {
    @weakify(self);
    self.lifeCycleListener = ^(ArgoViewControllerLifeCycleState state) {
        @strongify(self);
        if (state == ArgoViewControllerLifeCycleViewDidDisappear) {
            self.active = NO;
        } else if (state == ArgoViewControllerLifeCycleViewDidAppear) {
            self.active = YES;
        }
    };
    [self.viewController addLifeCycleListener:self.lifeCycleListener];
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (active && self.liveBlock) {
        dispatch_block_t block = self.liveBlock;
        block();
        self.liveBlock = nil;
    }
}

- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change {
    if (!self.active) {
        @weakify(self);
        self.liveBlock = ^{
            @strongify(self);
            [self receiveKeyPath:keyPath ofObject:object change:change];
        };
    } else {
        [self receiveKeyPath:keyPath ofObject:object change:change];
    }
}

- (void)receiveKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change {
    if (self.callback) {
        self.callback(keyPath, object, change);
    }
}

@end
