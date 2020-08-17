#import <UIKit/UIKit.h>

@class CellModelItem;
NS_ASSUME_NONNULL_BEGIN

@interface CellModel : NSObject 
@property (nonatomic, strong) CellModelItem* item;
#if DEBUG
+ (instancetype)defaultUserData;
#endif
NS_ASSUME_NONNULL_END
@end
    