//
//  ArgoViewController.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#import "ArgoViewController.h"
#import "MLNUIHeader.h"
#import "MLNUIKitInstanceFactory.h"
#import "MLNUIKitInstance.h"
#import "ArgoViewModelProtocol.h"

@interface ArgoViewController ()
@property (nonatomic, copy, readwrite) NSString *entryFileName;
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray <ArgoViewControllerLifeCycle> *lifeCycles;
@end

@implementation ArgoViewController

- (instancetype)initWithEntryFileName:(NSString *)entryFileName {
    return [self initWithEntryFileName:entryFileName bundle:[NSBundle mainBundle]];
}

- (instancetype)initWithEntryFileName:(NSString *)entryFileName bundle:(NSBundle *)bundle {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.entryFileName = entryFileName;
        self.bundle = bundle ?: [NSBundle mainBundle];
    }
    return self;
}

- (instancetype)initWithEntryFileName:(NSString *)entryFileName bundleName:(nullable NSString *)bundleName {
    NSBundle *bundle;
    if (!bundleName) {
        bundle = [NSBundle mainBundle];
    } else {
        NSArray *paths = [bundleName componentsSeparatedByString:@"."];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:paths.firstObject ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return [self initWithEntryFileName:entryFileName bundle:bundle];
}

- (instancetype)initWithModelClass:(Class<ArgoViewModelProtocol>)cls {
    NSString *f = [cls entryFileName];
    NSString *b = [cls bundleName];
    return [self initWithEntryFileName:f bundleName:b];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    PSTART(MLNUILoadTimeStatisticsType_Total);
    [self prepareForLoadEntryFile];
    NSError *error = nil;
    BOOL ret = [self.kitInstance runWithEntryFile:self.entryFileName windowExtra:self.extraInfo error:&error];
    PEND(MLNUILoadTimeStatisticsType_Total);
    PDISPLAY(2);

    if (ret) {
        if ([self.delegate respondsToSelector:@selector(viewController:didFinishRun:)]) {
            [self.delegate viewController:self didFinishRun:self.entryFileName];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(viewController:didFailRun:error:)]) {
            [self.delegate viewController:self didFailRun:self.entryFileName error:error];
        }
        MLNUIError(self.kitInstance.luaCore, @"run entryFile: %@, error: %@",self.entryFileName, error);
    }
    
    [self notifyLifeCycle:ArgoViewControllerLifeCycleViewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self notifyLifeCycle:ArgoViewControllerLifeCycleViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.kitInstance doLuaWindowDidAppear];
    [self notifyLifeCycle:ArgoViewControllerLifeCycleViewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self notifyLifeCycle:ArgoViewControllerLifeCycleViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.kitInstance doLuaWindowDidDisappear];
    [self notifyLifeCycle:ArgoViewControllerLifeCycleViewDidDisappear];
}

- (void)prepareForLoadEntryFile {
    [self.kitInstance changeRootView:self.view];
    [self.kitInstance changeLuaBundle:[[MLNUILuaBundle alloc] initWithBundle:self.bundle]];
    
//    self.globalModel = [NSMutableDictionary dictionary];
//    [self bindData:self.globalModel forKey:@"Global"];
}

//- (BOOL)regClasses:(NSArray<Class<MLNUIExportProtocol>> *)registerClasses {
//    return [self.kitInstance registerClasses:registerClasses error:NULL];
//}

- (void)notifyLifeCycle:(ArgoViewControllerLifeCycleState)state {
    for (ArgoViewControllerLifeCycle block in self.lifeCycles.copy) {
        block(state);
    }
}

- (void)addLifeCycleListener:(ArgoViewControllerLifeCycle)block {
    if (block) {
        [self.lifeCycles addObject:block];
    }
}

- (NSMutableArray *)lifeCycles {
    if (!_lifeCycles) {
        _lifeCycles = [NSMutableArray array];
    }
    return _lifeCycles;
}

- (MLNUIKitInstance *)kitInstance {
    if (!_kitInstance) {
        _kitInstance = [[MLNUIKitInstanceFactory defaultFactory] createKitInstanceWithViewController:self];
        if (self.regClasses) {
            [_kitInstance registerClasses:self.regClasses error:NULL];
        }
    }
    return _kitInstance;
}
@end
