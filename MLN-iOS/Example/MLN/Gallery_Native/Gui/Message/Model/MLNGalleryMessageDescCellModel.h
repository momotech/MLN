//
//  MLNGalleryMessageDescCellModel.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNGalleryMessageBaseCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMessageDescCellModel : MLNGalleryMessageBaseCellModel

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *attach;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) NSInteger follow;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
