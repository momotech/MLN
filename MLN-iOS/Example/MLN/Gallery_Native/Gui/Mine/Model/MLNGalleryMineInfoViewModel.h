//
//  MLNGalleryMineInfoViewModel.h
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNGalleryMineInfoNumberViewModel :  NSObject

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSString *desc;

- (instancetype)initWithDesc:(NSString *)desc number:(NSInteger)number;

@end

@interface MLNGalleryMineInfoViewModel : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location;

@property (nonatomic, strong) NSArray<MLNGalleryMineInfoNumberViewModel *> *infoNumbers;
@property (nonatomic, strong) NSString *clickTitle;

@property (nonatomic, copy) dispatch_block_t clickActionBlock;

@end

NS_ASSUME_NONNULL_END
