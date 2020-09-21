//
//  MLNUIViewController.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/4/24.
//

#import "MLNUIViewController.h"
#import "MLNUIHeader.h"
#import "MLNUIKitInstanceFactory.h"
#import "MLNUIKitInstance.h"

@interface MLNUIViewController ()
@property (nonatomic, copy, readwrite) NSString *entryFileName;
@property (nonatomic, strong) NSBundle *bundle;
//@property (nonatomic, strong) NSMutableDictionary *globalModel;
@end

@implementation MLNUIViewController

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
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return [self initWithEntryFileName:entryFileName bundle:bundle];
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
    }
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.kitInstance doLuaWindowDidAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.kitInstance doLuaWindowDidDisappear];
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
