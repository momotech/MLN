#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellModelItem : NSObject 
@property (nonatomic, copy) NSString * comment;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * pic;
@property (nonatomic, copy) NSString * desc;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, copy) NSString * icon;
@property (nonatomic, copy) NSString * like;
#if DEBUG
+ (instancetype)defaultUserData;
#endif
NS_ASSUME_NONNULL_END
@end
    