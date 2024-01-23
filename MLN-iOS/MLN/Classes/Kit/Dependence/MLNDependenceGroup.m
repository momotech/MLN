//
//  MLNDependenceGroup.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import "MLNDependenceGroup.h"
#import "MLNDependenceManager.h"

@interface MLNDependenceGroup()

@property(nonatomic, copy) NSString *gid;

@property(nonatomic, strong) NSMutableDictionary<NSString*,MLNDependenceWidget*> *allMap;

@end

@implementation MLNDependenceGroup

-(NSString *)gid {
    if (!_gid) {
        _gid = [NSString stringWithFormat:@"%@%@%@",self.name,kDependenceGroupIdSplit,self.version];
        _retryCount = 2;
    }
    return _gid;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"widgets"])
    {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *v = value;
            NSMutableArray<MLNDependenceWidget*> *widgets =[NSMutableArray arrayWithCapacity:v.count];
            for (NSDictionary *widget in v) {
                MLNDependenceWidget *w = [[MLNDependenceWidget alloc] init];
                [w setValuesForKeysWithDictionary:widget];
                [widgets addObject:w];
            }
            _directWidgets = widgets;
        }
    }
}

-(NSArray<MLNDependenceWidget*> *)allWidget {
    NSMutableArray *all = [NSMutableArray arrayWithArray:_directWidgets];
    return all;
}

-(NSDictionary<NSString *,MLNDependenceWidget *> *)allMap {
    if(!_allMap) {
        NSSet *allSet = [NSSet setWithArray:[self allWidget]];
        _allMap = [NSMutableDictionary dictionaryWithCapacity:allSet.count];
        for (MLNDependenceWidget *widget in allSet) {
            if (widget.name.length) {
                _allMap[widget.name] = widget;
            }
        }
    }
    return _allMap;
}

@end
