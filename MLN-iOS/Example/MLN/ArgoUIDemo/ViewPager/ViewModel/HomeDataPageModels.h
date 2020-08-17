#import <UIKit/UIKit.h>
#import "HomeDataPageModels.h"
#import "HomeDataPageModelsPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDataPageModels : NSObject

@property (nonatomic, strong) NSMutableArray <HomeDataPageModelsPage *> *page;


//#if DEBUG
+ (instancetype)defaultUserData;
//#endif


@end

NS_ASSUME_NONNULL_END
