//
//  MLNListViewObserver.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "MLNListViewObserver.h"
#import "MLNTableView.h"
#import "MLNKitViewController.h"
#import "MLNKitHeader.h"
#import "MLNCollectionView.h"

@interface MLNListViewObserver ()
@property (nonatomic, strong, readwrite) UIView *listView;
@end

@implementation MLNListViewObserver

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath {
    
    if ([listView isKindOfClass:[MLNTableView class]] || [listView isKindOfClass:[MLNCollectionView class]]) {
        MLNTableView *table = (MLNTableView *)listView;
        
        MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([table mln_luaCore]).viewController;
        MLNListViewObserver *observer = [[MLNListViewObserver alloc] initWithViewController:kitViewController callback:nil keyPath:keyPath];
        observer.listView = listView;
        return observer;
    }
    assert(false);
}

- (void)mergeAction:(MLNTableView *)table {
    [table.adapter tableViewReloadData:table.adapter.targetTableView];
    [table.adapter.targetTableView reloadData];
}

- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    [super notifyKeyPath:keyPath ofObject:object change:change];
    
    MLNTableView *table = (MLNTableView *)self.listView;
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(mergeAction:) object:table];
    [self performSelector:@selector(mergeAction:) withObject:table afterDelay:0];
    
    NSLog(@"keypath %@, object %@ change %@",keyPath, object, change);
    
    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    switch (type) {
        case NSKeyValueChangeSetting:
            break;
        case NSKeyValueChangeInsertion:
            break;
        case NSKeyValueChangeRemoval:
            break;
        case NSKeyValueChangeReplacement:
            break;
        default:
            break;
    }
}

- (void)dealloc {
    NSLog(@"---- %s",__FUNCTION__);
}
@end
