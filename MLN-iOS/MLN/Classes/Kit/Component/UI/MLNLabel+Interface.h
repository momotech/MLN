//
//  MLNLabel+Interface.h
//  MLN
//
//  Created by xue.yunqiang on 2022/8/26.
//

#import "MLNLabel.h"
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNLabel ()

@property (nonatomic, assign) MLNLabelMaxMode limitMode;
@property (nonatomic, strong) UILabel *innerLabel;

- (NSString *)remakeCacheKeyWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
@end

NS_ASSUME_NONNULL_END
