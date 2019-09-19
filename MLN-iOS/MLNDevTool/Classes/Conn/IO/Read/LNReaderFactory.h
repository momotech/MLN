//
//  MLNREaderFactory.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "LNReaderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNReaderFactory : NSObject;

+ (id<LNReaderProtocol>)getReader;

@end

NS_ASSUME_NONNULL_END
