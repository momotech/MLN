//
//  MLNDependenceWidget.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import "MLNDependenceWidget.h"
#import "MLNDependenceManager.h"

@interface MLNDependenceWidget()

@property(nonatomic, copy) NSString *wid;

@end

@implementation MLNDependenceWidget

-(NSString *)wid {
    if (!_wid) {
        _wid = [NSString stringWithFormat:@"%@%@%@",self.name,kDependenceWidgetIdSplit,self.version];
    }
    return _wid;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if([key isEqualToString:@"ios64"] &&
       [value isKindOfClass:[NSDictionary class]]) {
        id size = value[@"size"];
        if ([size isKindOfClass:[NSNumber class]]) {
            self.size = size;
        }
    }
}
#pragma mark - override
-(BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isMemberOfClass:[self class]]) {
        return NO;
    }
    MLNDependenceWidget *other = object;
    if ([self.name isEqualToString:other.name]){
        return YES;
    }
    return NO;
}

@end
