#import "UserData.h"
#import "UserDataListSourceReply.h"

@implementation UserData


+ (instancetype)modelForTest {
    UserData *ud = UserData.new;
    ud.title = @"ta的动态";
    ud.listSource = @[].mutableCopy;
    [ud.listSource addObject: [self testListSource1]];
    for (int i = 0; i < 50; i++) {
        [ud.listSource addObject: [self testListSource2]];
    }
    return ud;;
}

+ (UserDataListSource *)testListSource1 {
    UserDataListSource *us = UserDataListSource.new;
    us.icon = @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png";
    us.name = @"妮妮小丸子";
    us.desc = @"4分钟前.来自通讯录二度关系圈子";
    us.content = @"本仙女发大招啦，求夸三连！";
    us.actions = @[@"#晒妆容", @"求夸"].mutableCopy;
    us.pic = @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png";
    us.like = @"13";
    us.comment = @"253";
    return us;
}

+ (UserDataListSource *)testListSource2 {
    UserDataListSource *us = UserDataListSource.new;
    us.icon = @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png";
    us.name = @"我";
    us.level = @"青铜V";
    us.time = @"3分钟前";
    us.content = @"你P图水平不太行，照片还没本人好看";
    us.like = @"12";
    us.reply = @[].mutableCopy;
    
    NSArray *names = @[@"博彦", @"小妮子花花", @"博彦"];
    NSArray *contents = @[@"是手机不太行，记录不了你的美", @"你说的好假，我好喜欢", @"是手机不太行，记录不了你的美"];
    for (int i = 0; i < names.count; i++) {
        UserDataListSourceReply *r = UserDataListSourceReply.new;
        r.name = names[i];
        r.content = contents[i];
        [us.reply addObject:r];
    }
    return us;
}

@end
