//
//  MLNUITableViewAdapterProtocol.h
//  
//
//  Created by MoMo on 2019/2/19.
//

#ifndef MLNUITableViewAdapterProtocol_h
#define MLNUITableViewAdapterProtocol_h
#import <UIKit/UIKit.h>

@class MLNUITableView;
@protocol MLNUITableViewAdapterProtocol <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *targetTableView;
@property (nonatomic, weak) MLNUITableView *mlnuiTableView;

@optional
- (void)tableView:(UITableView *)tableView singleTapSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView longPressRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewReloadData:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)tableView:(UITableView *)tableView reloadSections:(NSIndexSet *)sections;
- (void)tableView:(UITableView *)tableView insertRowsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem;
- (void)tableView:(UITableView *)tableView deleteRowsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem indexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end

#endif /* MLNUITableViewAdapterProtocol_h */
