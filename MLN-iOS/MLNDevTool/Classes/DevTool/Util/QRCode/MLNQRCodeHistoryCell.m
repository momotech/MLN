//
//  MLNQRCodeHistoryCell.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#import "MLNQRCodeHistoryCell.h"
#import "MLNUtilBundle.h"

@interface MLNQRCodeHistoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end
@implementation MLNQRCodeHistoryCell

static NSString *defaultIconPath = nil;
- (void)awakeFromNib {
    [super awakeFromNib];
    if (!defaultIconPath) {
        defaultIconPath = [[MLNUtilBundle utilBundle] pngPathWithName:@"link"];
    }
    self.iconView.image = [UIImage imageNamed:defaultIconPath];
    self.linkLabel.text = nil;
    self.dateLabel.text = nil;
}

- (void)updateLink:(NSString *)link
{
    self.linkLabel.text = link;
}

- (void)updateDate:(NSString *)date
{
    self.dateLabel.text = date;
}

- (void)updateIcon:(NSString *)iconPath
{
    if (!iconPath || iconPath.length <= 0) {
        iconPath = defaultIconPath;
    }
    self.iconView.image = [UIImage imageNamed:iconPath];
}

@end
