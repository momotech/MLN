#import <UIKit/UIKit.h>
#import "HomeDataPageModelsPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDataPageModelsPage : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *like;
@property (nonatomic, copy) NSString *pic;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSMutableArray *commentArr;

//#if DEBUG
+ (instancetype)defaultUserData;
//#endif

@end

NS_ASSUME_NONNULL_END
