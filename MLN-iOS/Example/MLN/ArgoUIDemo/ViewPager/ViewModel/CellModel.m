#import "CellModel.h"
#import "CellModelItem.h"

@implementation CellModel

#if DEBUG
+ (instancetype)defaultUserData {
    CellModel *cellModel = [CellModel new];
CellModelItem *item = [CellModelItem new];
item.comment = @"253";
item.name = @"妮妮小丸子";
item.content = @"本仙女发大招啦，求夸三连！";
item.pic = @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png";
item.desc = @"4分钟前.来自通讯录二度关系圈子";
item.actions = @[
@"#晒妆容",
@"求夸",
].mutableCopy; 
item.icon = @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png";
item.like = @"13";
cellModel.item = item;


return cellModel;
}
#endif
@end
    