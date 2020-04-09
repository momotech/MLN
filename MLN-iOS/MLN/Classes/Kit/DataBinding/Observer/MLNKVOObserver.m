//
//  MLNKVOObserver.m
//  MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNKVOObserver.h"
#import "UIViewController+MLNKVO.h"
//#import "MLNKitHeader.h"
//#import "MLNKitViewController.h"
#import <pthread.h>
#import "MLNExtScope.h"

@interface MLNKVOObserver () {
    pthread_mutex_t _lock;
}

@property (nonatomic, copy) MLNViewControllerLifeCycleObserver observer;
@property (nonatomic, copy) void(^notifyLiveStickyBlock)(void);
@property (nonatomic, copy) MLNKVOCallback callback;
@property (nonatomic, weak, readwrite) UIViewController *viewController;
@property (nonatomic, copy, readwrite) NSString *keyPath;
@end

@implementation MLNKVOObserver

- (instancetype)init {
    self = [self initWithViewController:nil callback:nil keyPath:@""];
    if (self) {
    }
    return self;
}

- (instancetype)initWithViewController:(nullable UIViewController *)viewController callback:(nullable MLNKVOCallback)callback keyPath:(nonnull NSString *)keyPath {
    if (self = [super init]) {
        _active = YES;
        _keyPath = keyPath;
        LOCK_INIT();
        self.viewController = viewController;
        self.callback = callback;
        [self addViewControllerObserver:viewController];
        NSLog(@"---- init : %s %p",__FUNCTION__, self);

    }
    return self;
}

- (void)addViewControllerObserver:(UIViewController *)viewController {
    @weakify(self);
    self.observer = ^(MLNViewControllerLifeCycle state) {
        @strongify(self);
        if (state == MLNViewControllerLifeCycleViewDidDisappear) {
            self.active = NO;
        } else if (state == MLNViewControllerLifeCycleViewDidAppear) {
            self.active = YES;
        }
    };
    [viewController mln_addLifeCycleObserver:self.observer];
}

- (void)dealloc {
    LOCK_DESTROY();
    NSLog(@"---- dealloc : %s %p",__FUNCTION__, self);
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (active && self.notifyLiveStickyBlock) {
        LOCK();
        dispatch_block_t block = self.notifyLiveStickyBlock;
        UNLOCK();
        
        block();
        
        LOCK();
        self.notifyLiveStickyBlock = nil;
        UNLOCK();
    }
}

// eg: 这里的keypath是text, self.keyPath是userData.text
- (void)mln_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    if (!self.isActive) {
        __weak typeof(self) wself = self;
        LOCK();
        self.notifyLiveStickyBlock = ^{
            __strong typeof(wself) sself = wself;
            [sself notifyKeyPath:keyPath ofObject:object change:change];
        };
        UNLOCK();
    } else {
        [self notifyKeyPath:keyPath ofObject:object change:change];
    }
}

- (NSObject *)objectRetainingObserver {
    return nil;
}

- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    if (self.callback) {
        self.callback(keyPath, object, change);
    }
}

@end
