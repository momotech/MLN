//
//  MLNTestMe.h
//  MLNCore_Example
//
//  Created by MoMo on 2019/8/1.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MLNCore.h>
NS_ASSUME_NONNULL_BEGIN

@interface MLNTestMe : NSObject <MLNEntityExportProtocol>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL open;

@end

NS_ASSUME_NONNULL_END
