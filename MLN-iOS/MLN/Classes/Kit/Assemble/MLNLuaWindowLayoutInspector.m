//
//  MLNLuaWindowLayoutInspector.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/11.
//

#import "MLNLuaWindowLayoutInspector.h"
#import "MLNInspector.h"
#import "MLNViewLoadModel.h"

@implementation MLNLuaWindowLayoutInspector
- (void) execute:(MLNViewLoadModel *)loadModel {
    if (loadModel.rootView) {
        loadModel.size = loadModel.rootView.frame.size;
    }
    if (CGSizeEqualToSize(CGSizeZero, loadModel.size)) {
        loadModel.error = [[NSError alloc] initWithDomain:@"com.momo.mlnView" code:MLNLuaViewErrorLayoutInfo userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"layout basic info error", nil)}];
        return;
    }
    NSMutableDictionary *layoutInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    layoutInfo[@"heightLayoutStrategy"] = @(loadModel.heightLayoutStrategy);
    layoutInfo[@"widthLayoutStrategy"] = @(loadModel.widthLayoutStrategy);
    layoutInfo[@"size"] = @(loadModel.size);
    layoutInfo[@"identifier"] = @"MLNLuaView";
    [loadModel.windowExtro addEntriesFromDictionary:layoutInfo];
    return;
}
@end
