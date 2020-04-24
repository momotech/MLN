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
#import <pthread.h>
#import "MLNExtScope.h"
#import "MLNKitViewController+DataBinding.h"
#import "MLNDataBinding.h"
#import "NSArray+MLNKVO.h"

@interface MLNTableView (Internal)
- (void)lua_reloadData;
//- (void)lua_insertRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated;
//- (void)lua_deleteRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated;

- (void)lua_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated;
- (void)lua_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated;

//- (void)lua_reloadAtSection:(NSInteger)section animation:(BOOL)animation;
- (void)lua_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation;

@end

typedef BOOL(^ActionBlock)(void);

@interface MLNListViewObserver () {
//    pthread_mutex_t _lock;
}

@property (nonatomic, strong, readwrite) UIView *listView;
@property (nonatomic, strong) NSMutableArray <ActionBlock> *actions;
@property (nonatomic, weak) MLNKitViewController *kitViewController;
@end

@implementation MLNListViewObserver

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath {
    
    if ([listView isKindOfClass:[MLNTableView class]] || [listView isKindOfClass:[MLNCollectionView class]]) {
        MLNTableView *table = (MLNTableView *)listView;
        
        MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([table mln_luaCore]).viewController;
        MLNListViewObserver *observer = [[MLNListViewObserver alloc] initWithViewController:kitViewController callback:nil keyPath:keyPath];
        observer.listView = listView;
        observer.kitViewController = kitViewController;
        return observer;
    }
    assert(false);
}

- (instancetype)initWithViewController:(UIViewController *)viewController callback:(MLNKVOCallback)callback keyPath:(NSString *)keyPath {
    if (self = [super initWithViewController:viewController callback:callback keyPath:keyPath]) {
        self.actions = [NSMutableArray array];
    }
    return self;
}

- (void)mergeAction {
    NSArray <ActionBlock>*blocks = self.actions.copy;
    [self.actions removeAllObjects];
    dispatch_block_t doActions = ^{
        NSLog(@">>>> do actions count %zd",blocks.count);
        [blocks enumerateObjectsUsingBlock:^(ActionBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            *stop = obj();
        }];
    };
    
//    doActions();return;
    MLNTableView *list = (MLNTableView *)self.listView;
    if ([list isKindOfClass:[MLNTableView class]]) {
        UITableView *table = list.adapter.targetTableView;
        if (@available(iOS 11, *)) {
            [table performBatchUpdates:doActions completion:nil];
        } else {
            [table beginUpdates];
            doActions();
            [table endUpdates];
        }
    }
}

- (void)listViewReload:(UIView *)list {
    MLNTableView *table = (MLNTableView *)list;
    SEL sel = @selector(lua_reloadData);
    if ([table respondsToSelector:sel]) {
        [table lua_reloadData];
    }
}

- (void)listView:(UIView *)list reloadAtRow:(NSUInteger)row section:(NSUInteger)section {
    MLNTableView *table = (MLNTableView *)list;
    SEL sel = @selector(lua_reloadAtRow:section:animation:);
    if ([table respondsToSelector:sel]) { // + 1 模拟lua层调用
        [table lua_reloadAtRow:row + 1 section:section + 1 animation:NO];
    }
}

- (void)listView:(UIView *)list insertRowsAtSection:(NSUInteger)section startRow:(NSUInteger)startRow endRow:(NSUInteger)endRow object:(NSObject *)object {

    MLNTableView *table = (MLNTableView *)list;
    SEL sel = @selector(lua_insertRowsAtSection:startRow:endRow:animated:);
    if ([table respondsToSelector:sel]) { // + 1 模拟lua层调用
        [table lua_insertRowsAtSection:section + 1 startRow:startRow + 1 endRow:endRow + 1 animated:NO];
    }
}

- (void)listView:(UIView *)list deleteRowsAtSection:(NSUInteger)section startRow:(NSUInteger)startRow endRow:(NSUInteger)endRow object:(NSObject *)object {

    MLNTableView *table = (MLNTableView *)list;
    SEL sel = @selector(lua_deleteRowsAtSection:startRow:endRow:animated:);
    if ([table respondsToSelector:sel]) { // + 1 模拟lua层调用
        [table lua_deleteRowsAtSection:section + 1 startRow:startRow + 1 endRow:endRow + 1 animated:NO];
    }
}


// 对于ListViewObserver,keyPath is nil
- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    if ([NSThread isMainThread]) {
        [super notifyKeyPath:keyPath ofObject:object change:change];
        [self _mainThreadNotifyKeyPath:keyPath ofObject:object change:change];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [super notifyKeyPath:keyPath ofObject:object change:change];
            [self _mainThreadNotifyKeyPath:keyPath ofObject:object change:change];
        });
    }
}

- (void)_mainThreadNotifyKeyPath:(NSString *)keyPath ofObject:(NSArray *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
        
    NSParameterAssert([object isKindOfClass:[NSArray class]]);
    
//    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(mergeAction) object:nil];
//    [self performSelector:@selector(mergeAction) withObject:nil afterDelay:0];
//    NSLog(@"keypath %@, object %@ change %@",keyPath, object, change);
    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
    NSObject *old = [change objectForKey:NSKeyValueChangeOldKey];
    NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
    NSObject *tmp = new ? new : old;
    
    @weakify(self);
    ActionBlock action = ^BOOL{
        @strongify(self);
        if (!self) {
            return YES;
        }
        
        NSUInteger section = 0;
        NSUInteger startRow = indexSet.firstIndex;
        NSUInteger endRow = indexSet.firstIndex;
        
        if ([tmp isKindOfClass:[NSArray class]]) { //insert section，没有桥接，使用的应该不多
            section = indexSet.firstIndex;
            [self listViewReload:self.listView];
            return YES;
        } else if([object mln_is2D]  && tmp) {  //ex. object[0][0] = xx
            section = [object indexOfObject:tmp];
        }
        switch (type) {
    //        case NSKeyValueChangeSetting:
    //            break;
            case NSKeyValueChangeInsertion: {
                [self listView:self.listView insertRowsAtSection:section startRow:startRow endRow:endRow object:tmp];
            }
                break;
            case NSKeyValueChangeRemoval: {
                [self listView:self.listView deleteRowsAtSection:section startRow:startRow endRow:endRow object:tmp];
            }
                break;
            case NSKeyValueChangeReplacement:
                [self listView:self.listView reloadAtRow:startRow section:section];
                break;
            default:
                [self listViewReload:self.listView];
                break;
        }
        return NO;
    };
    action();
}

@end
