#import "HomeData.h"

@implementation HomeData

//#if DEBUG
+ (instancetype)defaultUserData {
    HomeData *homeData = [HomeData new];
    NSMutableArray *pages = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        HomeDataPageModels *m = [HomeDataPageModels defaultUserData];
        [pages addObject:m];
    }
    homeData.pageModels = pages;
    return homeData;
}
//#endif
@end
    
