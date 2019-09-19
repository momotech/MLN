//
//  MLNLabelT.h
//
//
//  Created by MoMo on 2018/11/12.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNLabel : UIView <MLNEntityExportProtocol>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSLineBreakMode lineBreakMode;
@property (nonatomic) CGFloat preferredMaxLayoutWidth;

@property (nonatomic, assign) BOOL autoFit;

@end

NS_ASSUME_NONNULL_END
