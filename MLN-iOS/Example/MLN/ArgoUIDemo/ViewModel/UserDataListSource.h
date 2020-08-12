#import <UIKit/UIKit.h>
#import "UserDataListSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserDataListSource : NSObject

@property (nonatomic, copy) NSString *like;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pic;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *reply;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *level;

@end

NS_ASSUME_NONNULL_END
