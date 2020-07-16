//
//  MLNUICollectionViewCell.h
//  
//
//  Created by MoMo on 2018/7/17.
//

#import <UIKit/UIKit.h>
#import "MLNUIReuseContentView.h"

#define kMLNUICollectionViewCellReuseID @"kMLNUICollectionViewCellReuseID"

@class MLNUICollectionViewCell;
@protocol MLNUICollectionViewCellDelegate <NSObject>

@optional
/// cell上的内容大小发生变更时回调
- (void)mlnuiCollectionViewCellShouldReload:(MLNUICollectionViewCell *)cell;

@end

@interface MLNUICollectionViewCell : UICollectionViewCell <MLNUIReuseCellProtocol>

@property (nonatomic, weak) id<MLNUICollectionViewCellDelegate> delegate;

@end
