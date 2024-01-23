//
//  MLNLuaViewErrorViewBuilder.m
//  MLN
//
//  Created by xue.yunqiang on 2022/1/24.
//

#import "MLNLuaViewDefaultErrorViewBuilder.h"
#import "MLNLuaViewErrorViewProtocol.h"

#define NoDataViewHeight 120

@interface MLNLuaViewDefaultErrorViewBuilder()
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, assign) CGFloat noDataViewWidth;
@end

@implementation MLNLuaViewDefaultErrorViewBuilder

-(UIView *) errorView:(MLNViewLoadModel *)loadModel {
    if (loadModel.widthLayoutStrategy != MLNLayoutMeasurementTypeIdle) {
        self.noDataViewWidth = loadModel.size.width;
    } else {
        self.noDataViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    return self.noDataView;
}

- (UIView *)noDataView {
    if (!_noDataView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.noDataViewWidth, NoDataViewHeight)];
        _noDataView = view;
        UIFont *titleFont = [UIFont systemFontOfSize:16.0];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_noDataView.frame), [titleFont lineHeight])];
        titleLabel.font = titleFont;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent ? [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1] : [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        titleLabel.userInteractionEnabled = YES;
        titleLabel.text = @"载入失败";
        [_noDataView addSubview:titleLabel];
    }
    return _noDataView;
}
@end
