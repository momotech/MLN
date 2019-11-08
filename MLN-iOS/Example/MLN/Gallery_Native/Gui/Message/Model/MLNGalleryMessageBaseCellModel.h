//
//  MLNGalleryMessageBaseCellModel
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMessageBaseCellModel : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) Class cellClass;

@property (nonatomic, assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
