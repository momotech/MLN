//
//  MLNTestModel.h
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNTestModel : NSObject
@property (nonatomic, assign, getter=isOpen) BOOL open;
@property (nonatomic, copy) NSString *text;
@end

NS_ASSUME_NONNULL_END
