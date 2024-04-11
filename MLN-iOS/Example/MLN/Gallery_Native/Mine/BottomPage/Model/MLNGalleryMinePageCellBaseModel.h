//
//  MLNGalleryMinePageCellBaseModel.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMinePageCellBaseModel : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) Class cellClass;

@end

NS_ASSUME_NONNULL_END
