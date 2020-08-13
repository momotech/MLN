#import <UIKit/UIKit.h>
#import "HomeDataPageModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeData : NSObject 
@property (nonatomic, strong) NSMutableArray <HomeDataPageModels *> *pageModels;
#if DEBUG
+ (instancetype)defaultUserData;
#endif
NS_ASSUME_NONNULL_END
@end
    
