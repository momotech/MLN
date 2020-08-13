#import "HomeDataPageModelsPage.h"

@implementation HomeDataPageModelsPage

#if DEBUG
+ (instancetype)defaultUserData {
    HomeDataPageModelsPage *item = [HomeDataPageModelsPage new];
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
    item.commentArr = @[
        @"太太羡慕了有",
        @"太仙仙女在人间",
        @"太赞",
        @"超级赞超级赞超级赞超级赞仙女在人间人间",
        @"太羡慕了有钱了也想去超级赞超",
        @"仙女在人间赞超级赞仙女在人女在人间",
        @"仙女在人间",
        @"超级赞超级赞超级赞超级赞",
        @"太羡慕了有钱了也想去",
        @"太羡慕了有钱了也想去",
        @"仙仙女在人间",
        @"超级赞超级赞超级赞",
        @"超级赞超级赞超级赞超级赞仙女在人间人间",
        @"太羡慕了有钱了也想去超级赞超",
        @"仙女在人间赞超级赞仙女在人女在人间",
        @"仙女在人间",
        @"超级赞超级赞超级赞超级赞",
        @"太羡慕了有钱了也想去",
        @"太羡慕了有钱了也想去",
        @"仙仙女在人间",
        @"超级赞超级赞超级赞",
        @"超级赞超级赞超级赞超级赞仙女在人间人间",
        @"太羡慕了有钱了也想去超级赞超",
        @"仙女在人间赞超级赞仙女在人女在人间",
    ].mutableCopy;
    return item;
}
#endif

@end
