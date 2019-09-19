//
//  MLNTableViewAdapterProtocol.h
//  
//
//  Created by MoMo on 2019/2/19.
//

#ifndef MLNTableViewAdapterProtocol_h
#define MLNTableViewAdapterProtocol_h
#import <UIKit/UIKit.h>

@protocol MLNTableViewAdapterProtocol <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *targetTableView;

@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView longPressRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewReloadData:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)tableView:(UITableView *)tableView reloadSections:(NSIndexSet *)sections;
- (void)tableView:(UITableView *)tableView insertRowsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem;
- (void)tableView:(UITableView *)tableView deleteRowsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem indexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end

#endif /* MLNTableViewAdapterProtocol_h */
