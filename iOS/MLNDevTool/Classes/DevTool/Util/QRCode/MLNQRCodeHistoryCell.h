//
//  MLNQRCodeHistoryCell.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNQRCodeHistoryCell : UITableViewCell

- (void)updateLink:(NSString *)link;
- (void)updateDate:(NSString *)date;
- (void)updateIcon:(NSString * __nullable)iconPath;

@end

NS_ASSUME_NONNULL_END
