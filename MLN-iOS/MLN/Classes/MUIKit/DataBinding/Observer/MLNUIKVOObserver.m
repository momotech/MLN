//
//  MLNUIKVOObserver.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNUIKVOObserver.h"
#import "UIViewController+MLNUIKVO.h"
//#import "MLNUIKitHeader.h"
#import <pthread.h>
#import "MLNUIExtScope.h"

@interface MLNUIKVOObserver () {
    pthread_mutex_t _lock;
}

@property (nonatomic, copy) MLNUIViewControllerLifeCycleObserver observer;
@property (nonatomic, copy) void(^notifyLiveStickyBlock)(void);
@property (nonatomic, copy) MLNUIKVOCallback callback;
@property (nonatomic, weak, readwrite) UIViewController *viewController;
@property (nonatomic, copy, readwrite) NSString *keyPath;
@end

@implementation MLNUIKVOObserver

- (instancetype)init {
    self = [self initWithViewController:nil callback:nil keyPath:@""];
    if (self) {
    }
    return self;
}

- (instancetype)initWithViewController:(nullable UIViewController *)viewController callback:(nullable MLNUIKVOCallback)callback keyPath:(nonnull NSString *)keyPath {
    if (self = [super init]) {
        _active = YES;
        _keyPath = keyPath;
        LOCK_INIT();
        self.viewController = viewController;
        self.callback = callback;
        [self addViewControllerObserver:viewController];
    }
    return self;
}

- (void)addViewControllerObserver:(UIViewController *)viewController {
    @weakify(self);
    self.observer = ^(MLNUIViewControllerLifeCycle state) {
        @strongify(self);
        if (state == MLNUIViewControllerLifeCycleViewDidDisappear) {
            self.active = NO;
        } else if (state == MLNUIViewControllerLifeCycleViewDidAppear) {
            self.active = YES;
        }
    };
    [viewController mlnui_addLifeCycleObserver:self.observer];
}

- (void)dealloc {
    LOCK_DESTROY();
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
- (void)mlnui_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
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
