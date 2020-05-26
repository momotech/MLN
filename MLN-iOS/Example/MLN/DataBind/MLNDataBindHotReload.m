//
//  MLNDataBindHotReload.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/3/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBindHotReload.h"
#import "MLNStaticTest.h"
#import "MLNDataBindModel.h"
#import <NSArray+MLNUIKVO.h>
#import "MLNBindTestCaseModel.h"
#import "MLNDataBindOperator.h"
#import "MLNUIKit.h"

@interface MLNDataBindHotReload () <MLNUIDataBindingProtocol>
@property (nonatomic, strong) MLNBindTestCaseModel *tcModel;
@end

@implementation MLNDataBindHotReload

- (instancetype)init {
    self = [super initWithEntryFileName:@"" bundle:nil];
    self.regClasses = @[[MLNStaticTest class], [MLNDataBindOperator class]];
    if (self) {
        NSLog(@"---- %s",__FUNCTION__);
        [MLNDataBindOperator setHotReload:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

//- (void)createTestCase {
//    self.tcModel = [MLNBindTestCaseModel testModel];
//    [self bindData:self.tcModel forKey:@"testModel"];
//    MLNBindTestCaseModel2 *tc2 = [MLNBindTestCaseModel2 testModel];
//    [self bindData:tc2 forKey:@"pageModel"];
//}

- (void)dealloc {
    NSLog(@"---- dealloc : %s ",__func__);
}

#pragma mark - MLNUIDataBindingProtocol

- (MLNUIDataBinding *)mlnui_dataBinding {
    if (!_dataBinding) {
        _dataBinding = [MLNUIDataBinding new];
    }
    return _dataBinding;
}
//- (void)bindData:(NSObject *)data forKey:(NSString *)key {
//    [self.mlnui_dataBinding bindData:data forKey:key];
//}

@end
