//
//  MLNQRCodeResultManager.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#import <Foundation/Foundation.h>
#import "MLNQRCodeHistoryInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface MLNQRCodeResultManager : NSObject

- (id<MLNQRCodeHistoryInfoProtocol>)resultAtIndex:(NSUInteger)index;
- (void)addResult:(NSString *)result;

- (void)removeResult:(NSString *)result;
- (void)removeAll;

- (NSUInteger)resultsCount;

@end

NS_ASSUME_NONNULL_END
