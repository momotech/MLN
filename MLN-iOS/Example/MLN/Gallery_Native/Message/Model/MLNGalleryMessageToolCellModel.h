//
//  MLNGalleryMessageToolCellModel.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNGalleryMessageBaseCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMessageToolCellModel : MLNGalleryMessageBaseCellModel

@property (nonatomic, copy) NSString *leftIcon;
@property (nonatomic, copy) NSString *rightIcon;
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
