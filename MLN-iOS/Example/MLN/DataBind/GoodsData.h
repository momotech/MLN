#import <UIKit/UIKit.h>
#import "GoodsDataList.h"
#import "GoodsData.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoodsData : NSObject

@property (nonatomic, assign) NSInteger totalPrice;
@property (nonatomic, assign) NSInteger totalNum;
@property (nonatomic, strong) NSMutableArray<GoodsDataList *> *list;

@end

NS_ASSUME_NONNULL_END
