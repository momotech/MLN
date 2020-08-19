#import "HomeDataPageModels.h"



@implementation HomeDataPageModels


//#if DEBUG
+ (instancetype)defaultUserData {
    HomeDataPageModels *model = [HomeDataPageModels new];
    NSMutableArray *page = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        HomeDataPageModelsPage *p = [HomeDataPageModelsPage defaultUserData];
        [page addObject:p];
    }
    model.page = page;
    return model;
}
//#endif


@end
