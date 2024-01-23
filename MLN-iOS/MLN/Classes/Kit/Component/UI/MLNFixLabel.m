//
//  MLNFixLable.m
//  MLN
//
//  Created by xue.yunqiang on 2022/8/26.
//

#import "MLNFixLabel.h"
#import "MLNViewExporterMacro.h"
#import "MLNKitHeader.h"
#import "MLNKitInstance.h"
#import "MLNLayoutEngine.h"
#import "MLNTextConst.h"
#import "MLNViewConst.h"
#import "MLNFont.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNSizeCahceManager.h"
#import "MLNBeforeWaitingTask.h"
#import "NSAttributedString+MLNKit.h"
#import "MLNStyleString.h"
#import "MLNLabel+Interface.h"

@implementation MLNFixLabel

#pragma mark - Layout For Lua
- (CGSize)lua_measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    NSString *cacheKey = [self remakeCacheKeyWithMaxWidth:maxWidth maxHeight:maxHeight];
    MLNSizeCahceManager *sizeCacheManager = MLN_KIT_INSTANCE(self.mln_luaCore).layoutEngine.sizeCacheManager;
    NSValue *sizeValue = [sizeCacheManager objectForKey:cacheKey];
    switch (self.limitMode) {
        case MLNLabelMaxModeValue:
            self.innerLabel.numberOfLines = 0;
            break;
        default:
            break;
    }
    if (sizeValue) {
        return sizeValue.CGSizeValue;
    }
    maxWidth -= self.lua_paddingLeft + self.lua_paddingRight;
    maxHeight -= self.lua_paddingTop + self.lua_paddingBottom;
    CGSize size = [self.innerLabel sizeThatFits:CGSizeMake(maxWidth, maxHeight)];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    size.width = size.width + self.lua_paddingLeft + self.lua_paddingRight;
    size.height = size.height + self.lua_paddingTop + self.lua_paddingBottom;
    [sizeCacheManager setObject:[NSValue valueWithCGSize:size] forKey:cacheKey];
    return size;
}


#pragma mark - Export To Lua
LUA_EXPORT_VIEW_BEGIN(MLNFixLabel)
LUA_EXPORT_VIEW_END(MLNFixLabel, FixLabel, YES, "MLNLabel", "initWithLuaCore:frame:")

@end
