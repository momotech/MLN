//
//  MLNSpacerNode.m
//  MLN
//
//  Created by MOMO on 2020/3/27.
//

#import "MLNSpacerNode.h"
#import "MLNHStackNode.h"
#import "MLNVStackNode.h"
#import "MLNKitHeader.h"
#import "MLNView.h"

@interface MLNSpacerNode ()

@property (nonatomic, assign) BOOL changedWidth;
@property (nonatomic, assign) BOOL changedHeight;

@end

@implementation MLNSpacerNode

#pragma mark - Override

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    MLNLayoutNode *superNode = self.supernode;
    if ([superNode isKindOfClass:[MLNHStackNode class]] ||
        [superNode isKindOfClass:[MLNVStackNode class]]) {
        self.measuredWidth = self.width;
        self.measuredHeight = self.height;
        return CGSizeMake(self.measuredWidth, self.measuredHeight);
    }
    MLNLuaAssert(((MLNView *)self.targetView).mln_luaCore, NO, @"The Spacer is only valid in HStack and VStack.");
    return CGSizeZero;
}

- (BOOL)isSpacerNode {
    return YES;
}

- (void)changeWidth:(CGFloat)width {
    [super changeWidth:width];
    _changedWidth = YES;
}

- (void)changeHeight:(CGFloat)height {
    [super changeHeight:height];
    _changedHeight = YES;
}

@end
