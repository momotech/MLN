#import <UIKit/UIKit.h>
#import "ArgoKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserData : ArgoViewModelBase <ArgoViewModelProtocol>
@property (nonatomic, strong) ArgoObservableArray *listSource;
@property (nonatomic, copy) NSString * title;

//#if DEBUG
+ (instancetype)defaultUserData;
//#endif
NS_ASSUME_NONNULL_END
@end
    
