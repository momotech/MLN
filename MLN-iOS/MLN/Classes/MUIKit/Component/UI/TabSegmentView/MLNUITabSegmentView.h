//
//  MLNUITabSegmentView.h
//  MLNUI
//
//  Created by MoMo on 2019/1/16.
//

#import <UIKit/UIKit.h>
#import "MLNUIView.h"
#import "MLNUITabSegmentScrollHandler.h"
#import "MLNUITabSegmentViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUITabSegmentViewConfiguration, MLNUITabSegmentLabel;

typedef void (^MLNUITabSegmentViewTapActionBlock) (MLNUITabSegmentView *tapView, NSInteger index);

@interface MLNUITabSegmentView : MLNUIView

@property (nonatomic, weak) id<MLNUITabSegmentViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, strong, readonly) MLNUITabSegmentViewConfiguration *configuration;

@property (nonatomic, strong, readonly) UIScrollView      *contentScrollView;
@property (nonatomic, strong, readonly) NSArray<MLNUITabSegmentLabel *> *segmentViews;
@property (nonatomic, strong, readonly) UIImageView       *bottomPointView;

- (void)refreshSegmentTitles:(NSArray<NSString*> *)segmentTitles;
- (void)setCurrentLabelIndex:(NSInteger)currentIndex animated:(BOOL)animated;

- (void)setTapTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)setTapBadgeNum:(NSInteger)num atIndex:(NSInteger)index;
- (void)setTapBadgeTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)setRedDotHidden:(BOOL)hidden adIndex:(NSInteger)index;
- (void)setTabSegmentHidden:(BOOL)hidden adIndex:(NSInteger)index;

- (void)setShowArrowActionWithBlock:(void(^)(NSInteger index))block atIndexs:(NSArray *)indexs;

- (void)animtionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end

@interface MLNUITabSegmentViewConfiguration : NSObject

//均为没选中放大情况下计算
@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat rightPadding;
@property (nonatomic, assign) CGFloat itemPadding;

@property (nonatomic, assign) CGFloat normalFontSize;
@property (nonatomic, assign) CGFloat selectScale;

@property (nonatomic, strong) UIColor *customTiniColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, assign) CGFloat pointInsetBottom;
@property (nonatomic, assign) CGSize pointSize;
@property (nonatomic, assign) CGSize redDotSize;

+ (instancetype)defaultConfiguration;

+ (UIFontWeight)getFontWeightWithProgress:(CGFloat)progress;

- (UIColor *)getColorWithProgress:(CGFloat)progress;

@end

@interface MLNUITabSegmentLabel : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL enableShowArrow;

- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize;

- (void)setLabelScale:(CGFloat)scale fontWeight:(UIFontWeight)fontWeight;
- (void)reLayoutLabel;

- (void)setText:(NSString *)text;
- (void)setBadgeNum:(NSInteger)num;
- (void)setBadgeTitle:(NSString*)title;
- (void)setRedDotHidden:(BOOL)hidden;
- (void)resetRedDotSize:(CGSize)size;

@end


NS_ASSUME_NONNULL_END
