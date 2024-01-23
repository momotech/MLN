//
//  MLNDependenceModel.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import "MLNDependenceModel.h"

@implementation MLNDependenceModel

-(void)transfromDicToModel:(NSDictionary *) sourceDic {
    if (!sourceDic.count) {
        return;
    }

    NSArray *groupArray = sourceDic[@"group"];
    if (!groupArray.count) {
        return;
    }
    NSMutableArray *groupModelArr = [NSMutableArray arrayWithCapacity:groupArray.count];
    for (NSDictionary *groupDic in groupArray) {
        MLNDependenceGroup *group = [[MLNDependenceGroup alloc] init];
        [group setValuesForKeysWithDictionary:groupDic];
        [groupModelArr addObject:group];
    }
    _group = groupModelArr;
}

@end
