#import <UIKit/UIKit.h>
#import "UserDataListSource.h"
#import "UserData.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray<UserDataListSource *> *listSource;

+ (instancetype)modelForTest;

@end

NS_ASSUME_NONNULL_END
