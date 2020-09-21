//
//  ArgoObserverHelper.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import "ArgoObserverHelper.h"
#import "ArgoKitDefinitions.h"

@implementation ArgoObserverHelper

//+ (void)load {
////    NSString *keypath = @"a.b.1.c.2";
//    NSArray *kps = @[@"a.b.1.c", @"a.b.1.2.d.e"];
//    for (NSString *keypath in kps) {
//        NSArray *array = [keypath componentsSeparatedByString:@"."];
//        NSInteger idx = [self lastNumberIndexOf:array];
//        if (idx != NSNotFound) {
//            NSString *befor = [self stringBefor:idx withKeys:array];
//            NSString *after = [keypath substringFromIndex:befor.length + 1];
//            NSLog(@"");
//        }
//    }
//}

+ (BOOL)isNumber:(NSString *)str {
    int n = str.intValue;
    if (n == 0) {
        return [str isEqualToString:@"0"];
    }
    return YES;
}

+ (NSInteger)lastNumberIndexOf:(NSArray <NSString *> *)keys {
    NSInteger idx = NSNotFound;
    for (NSUInteger i = keys.count - 1; i > 0; i--) {
        if ([self isNumber:keys[i]]) {
            idx = i;
            break;
        }
    }
    return idx;
}

+ (NSString *)stringBefor:(NSInteger)index withKeys:(NSArray<NSString *> *)keys {
    NSArray *newKeys = [keys subarrayWithRange:NSMakeRange(0, index + 1)];
    NSString *string = [newKeys componentsJoinedByString:kArgoConstString_Dot];
    return string;
}

+ (BOOL)arrayIs2D:(NSArray *)array {
    if (array && [array.firstObject isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)hasNumberInKeys:(NSArray *)keys fromIndex:(int)index {
    BOOL hasNumber = NO;
    for (int i = index; i < keys.count; i++) {
        if ([self isNumber:keys[i]]) {
            hasNumber = YES;
            break;
        }
    }
    return hasNumber;
}

@end
