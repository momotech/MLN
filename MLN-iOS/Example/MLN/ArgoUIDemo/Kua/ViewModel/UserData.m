#import "UserData.h"

@implementation UserData

+ (NSString *)entryFileName {
    return @"kuaDetail.lua";
}

+ (NSString *)bundleName {
    return @"KuaDemoMUI";
}

#if OCPERF_USE_NEW_DB
- (NSString *)title {
    return [self valueForKey:@"title"];
}
-(void)setTitle:(NSString *)title {
    [self setValue:title forKey:@"title"];
}
-(ArgoObservableArray *)listSource {
    return [self valueForKey:@"listSource"];
}
- (void)setListSource:(ArgoObservableArray *)listSource {
    [self setValue:listSource forKey:@"listSource"];
}
#endif

+ (NSString *)modelKey {
 return @"userData";
}

+ (void)load {
    [self defaultUserData];
}

//#if DEBUG
+ (instancetype)defaultUserData {
    static UserData *userData;
    if (userData) {
        return userData;
    }
    userData = [self new];
userData.listSource = @[
@{
@"actions": @[
@"#晒妆容",
@"求夸",
].argo_mutableCopy,
@"comment": @"253",
@"name": @"妮妮小丸子",
@"content": @"本仙女发大招啦，求夸三连！",
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"pic": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"like": @"13",
@"desc": @"4分钟前.来自通讯录二度关系圈子",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
@{
@"level": @"青铜V",
@"name": @"我",
@"reply": @[
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
@{
@"name": @"小妮子花花",
@"content": @"你说的好假，我好喜欢",
}.argo_mutableCopy,
@{
@"name": @"博彦",
@"content": @"是手机不太行，记录不了你的美",
}.argo_mutableCopy,
].argo_mutableCopy,
@"icon": @"https://f.msup.com.cn/07ae2565138eafe695ff029014d944b7.png",
@"time": @"3分钟前",
@"like": @"12",
@"content": @"你P图水平不太行，照片还没本人好看",
}.argo_mutableCopy,
].argo_mutableCopy;
userData.title = @"ta的动态";

return userData;
}
//#endif
@end
    
