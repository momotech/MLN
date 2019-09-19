//
//  MLNInnerCollectionView.h
//  MLN
//
//  Created by MoMo on 2019/9/2.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNLuaCore;
@interface MLNInnerCollectionView : UICollectionView

@property (nonatomic, weak) id<MLNEntityExportProtocol> containerView;

- (MLNLuaCore *)mln_luaCore;

@end

NS_ASSUME_NONNULL_END
