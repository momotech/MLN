//
//  MLNQRCodeHistoryViewController.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/13.
//

#import "MLNQRCodeHistoryViewController.h"
#import "MLNUtilBundle.h"
#import "MLNQRCodeHistoryCell.h"

@interface MLNQRCodeHistoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewTop;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;

@end

@implementation MLNQRCodeHistoryViewController

+ (instancetype)historyViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MLNQRCodeHistoryViewController" bundle:[MLNUtilBundle utilBundle]];
    return [storyBoard instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *titleIconPath = [[MLNUtilBundle utilBundle] pngPathWithName:@"history"];
    self.titleIcon.image = [UIImage imageNamed:titleIconPath];
    
    NSString *closeBtnPath = [[MLNUtilBundle utilBundle] pngPathWithName:@"close"];
    [self.closeBtn setImage:[UIImage imageNamed:closeBtnPath] forState:UIControlStateNormal];
    self.closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.closeBtn.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *clearBtnPath = [[MLNUtilBundle utilBundle] pngPathWithName:@"clean"];
    [self.clearBtn setImage:[UIImage imageNamed:clearBtnPath] forState:UIControlStateNormal];
    self.closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.closeBtn.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"MLNQRCodeHistoryCell" bundle:[MLNUtilBundle utilBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MLNQRCodeHistoryCell"];
}

- (IBAction)closeAction:(id)sender {
    if ([self.adapter respondsToSelector:@selector(closeHistoryViewController:)]) {
        return [self.adapter closeHistoryViewController:self];
    }
}

- (IBAction)clearAction:(id)sender {
    if ([self.adapter respondsToSelector:@selector(clearInfos:)]) {
        return [self.adapter clearInfos:self];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MLNQRCodeHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MLNQRCodeHistoryCell" forIndexPath:indexPath];
    if ([self.adapter respondsToSelector:@selector(historyViewController:infoForRowAtIndexPath:)]) {
        id<MLNQRCodeHistoryInfoProtocol> info = [self.adapter historyViewController:self infoForRowAtIndexPath:indexPath];
        [cell updateLink:[info link]];
        [cell updateDate:[info date]];
        [cell updateIcon:[info iconName]];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.adapter respondsToSelector:@selector(numberOfInfos:)]) {
        return [self.adapter numberOfInfos:self];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.adapter respondsToSelector:@selector(historyViewController:didSelectRowAtIndexPath:)]) {
        return [self.adapter historyViewController:self didSelectRowAtIndexPath:indexPath];
    }
}

@end
