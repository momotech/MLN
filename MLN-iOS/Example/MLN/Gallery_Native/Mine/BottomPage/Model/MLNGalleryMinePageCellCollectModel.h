//
//  MLNGalleryMinePageCellCollectModel.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMinePageCellBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMinePageCellCollectCellModel : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *righticon;

@end

@interface MLNGalleryMinePageCellCollectModel : MLNGalleryMinePageCellBaseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *buttonTitle;

@property (nonatomic, strong) NSArray<MLNGalleryMinePageCellCollectCellModel *>* dataCellModels;

@property (nonatomic, copy) dispatch_block_t clickActionBlock;

@end

NS_ASSUME_NONNULL_END
