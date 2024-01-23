//
//  MLNFixLable.h
//  MLN
//
//  Created by xue.yunqiang on 2022/8/26.
//

#import "MLNLabel.h"
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/* MLNFixLable
 * MLNFixLable is fix MLNLabel layout method redundant calculate in lineSpace aspect
 *
 * Whenever possible, use the `MLNFixLable` class on `MLNLable` instead.
 */
@interface MLNFixLabel : MLNLabel <MLNEntityExportProtocol>

@end

NS_ASSUME_NONNULL_END
