#import <UIKit/UIKit.h>
#import "ArgoKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserData : ArgoObservableMap
@property (nonatomic, strong) ArgoObservableArray *listSource;
@property (nonatomic, copy) NSString * title;

+ (NSString *)modelKey;

#if DEBUG
+ (instancetype)defaultUserData;
#endif
NS_ASSUME_NONNULL_END
@end
    
