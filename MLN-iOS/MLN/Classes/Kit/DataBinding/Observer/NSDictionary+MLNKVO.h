//
//  NSDictionary+MLNKVO.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MLNKVO)
- (NSMutableDictionary *)mln_mutalbeCopy;
- (NSDictionary *)mln_convertToLuaTableAvailable;
- (NSMutableDictionary *)mln_convertToMDic;
@end

@interface NSMutableDictionary (MLNKVO)
- (NSDictionary *)mln_copy;
@end

NS_ASSUME_NONNULL_END
