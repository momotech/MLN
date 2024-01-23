//
//  MLNViewLoader.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import "MLNViewLoader.h"
#import "MLNViewInspectorManager.h"
#import "MLNViewLoadModel.h"

@implementation MLNViewLoader

- (void)loadView:(MLNViewLoadModel *) loadModel  {
    NSAssert(_inspectorManager != nil, @"filterManager cant't be nil");
    [_inspectorManager inspectorLoad:loadModel];
}

@end
