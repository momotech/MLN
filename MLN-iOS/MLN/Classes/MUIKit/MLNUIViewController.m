//
//  MLNUIViewController.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/4/24.
//

#import "MLNUIViewController.h"
#import "MLNUIKit.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    PSTART(MLNUILoadTimeStatisticsType_Total);
    CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();
    [self prepareForLoadEntryFile];
    NSError *error = nil;
    BOOL ret = [self.kitInstance runWithEntryFile:self.entryFileName windowExtra:self.extraInfo error:&error];
    printf(">>>>> total cost %.2f ms \n", (CFAbsoluteTimeGetCurrent() - s) * 1000);
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
