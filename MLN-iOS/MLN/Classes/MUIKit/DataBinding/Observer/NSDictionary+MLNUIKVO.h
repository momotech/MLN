//
//  NSDictionary+MLNUIKVO.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MLNUIKVO)
- (NSMutableDictionary *)mln_mutalbeCopy;
- (NSDictionary *)mln_convertToLuaTableAvailable;
- (NSMutableDictionary *)mln_convertToMDic;
@end

@interface NSMutableDictionary (MLNUIKVO)
- (NSDictionary *)mln_copy;
@end

NS_ASSUME_NONNULL_END
