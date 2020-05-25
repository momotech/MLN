//
//  NSDictionary+MLNUIKVO.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MLNUIKVO)
- (NSMutableDictionary *)mlnui_mutalbeCopy;
- (NSDictionary *)mlnui_convertToLuaTableAvailable;
- (NSMutableDictionary *)mlnui_convertToMDic;
@end

@interface NSMutableDictionary (MLNUIKVO)
- (NSDictionary *)mlnui_copy;
@end

NS_ASSUME_NONNULL_END
