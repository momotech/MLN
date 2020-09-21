//
//  DemoLiyifengTableView.m
//  MyFirstDemo
//
//  Created by MOMO on 2020/9/2.
//  Copyright © 2020 MOMO. All rights reserved.
//

#define ssRGB(r, g, b) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define ssRGBAlpha(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#import <Masonry/Masonry.h>

#import <SDWebImage/SDWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <YYModel/YYModel.h>

#import "DemoLiyifengViewController.h"

#import "DemoLiyifengTableViewCell.h"
#import "DemoLiyifengTableViewHeaderCell.h"

//#import "DemoFirstViewController.h"

#import "DemoLiyifengModel.h"


NSString *CellInfo = @"CellInformation";
NSString *CellHeader = @"CellHeader";

@interface DemoLiyifengViewController ()
@property (nonatomic, strong) NSArray <DemoLiyifengModel *>*models;
@end

@implementation DemoLiyifengViewController

static NSArray *testModels;
+ (void)load {
    NSArray *fansData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil]];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        [arr addObject:[fansData objectAtIndex:i % fansData.count]];
    }
    testModels = [NSArray yy_modelArrayWithClass:DemoLiyifengModel.class json:arr];
}

//自定义标签样式方法
-(UILabel *)tagLabelWithText:(NSString *)text textColor:(UIColor *)textColor {
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = textColor ? textColor : [UIColor blackColor];
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"#李易峰的超话";
    self.navigationController.navigationBar.barTintColor = ssRGBAlpha(250, 128, 114, 1);
    
//    NSArray *fansData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil]];
    
//    [fansData writeToFile:@"/Users/momo/Desktop/data.plist" atomically:YES];
    
//    self.models = [NSArray yy_modelArrayWithClass:DemoLiyifengModel.class json:fansData];
    self.models = testModels;
    
    UITableView *LiyifengTableView = [UITableView new];
    [self.view addSubview:LiyifengTableView];
    
    [LiyifengTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    LiyifengTableView.delegate = self;
    LiyifengTableView.dataSource = self;
    
    [LiyifengTableView registerClass:[DemoLiyifengTableViewCell class] forCellReuseIdentifier: CellInfo];
    
    [LiyifengTableView registerClass:[DemoLiyifengTableViewHeaderCell class] forCellReuseIdentifier: CellHeader];
    
    LiyifengTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    LiyifengTableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
    return self.models.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        
        return  [tableView dequeueReusableCellWithIdentifier:CellHeader forIndexPath:indexPath];;
 
    }else{
        
        DemoLiyifengTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellInfo forIndexPath:indexPath];
        
        cell.LiyifengTableViewCellModel = self.models[indexPath.row - 1];
        
        return cell;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath{
//    if (indexPath.row == 0) {
//        return self.view.frame.size.height;
//    }
//    return 190;
//}

- (void)dismiss:(UIAlertView *)alert{
    [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
}

@end
