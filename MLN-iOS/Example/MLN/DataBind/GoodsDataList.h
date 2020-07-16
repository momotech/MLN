#import <UIKit/UIKit.h>
#import "GoodsDataList.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoodsDataList : NSObject

@property (nonatomic, assign) CGFloat discount;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
