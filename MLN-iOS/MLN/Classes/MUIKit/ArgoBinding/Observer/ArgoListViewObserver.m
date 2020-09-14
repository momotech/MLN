//
//  ArgoListViewObserver.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/30.
//

#import "ArgoListViewObserver.h"
#import "MLNUITableView.h"
#import <UIKit/UIKit.h>
#import "MLNUIKitHeader.h"
#import "MLNUICollectionView.h"
#import <pthread.h>
#import "MLNUIExtScope.h"
#import "MLNUIDataBinding.h"
#import "NSArray+MLNUIKVO.h"
#import "NSObject+MLNUIKVO.h"
#import "NSObject+MLNUIDealloctor.h"
#import "ArgoListenerProtocol.h"

static NSString *const kUpdateNotiKey = @"MLNUIListView_Update";

@protocol _MLNUIListInternalRefreshProtocol <NSObject>
- (void)luaui_reloadData;
//- (void)luaui_insertRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated;
//- (void)luaui_deleteRow:(NSInteger)row section:(NSInteger)section animated:(BOOL)animated;
- (void)luaui_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated;
- (void)luaui_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated;

//- (void)luaui_reloadAtSection:(NSInteger)section animation:(BOOL)animation;
- (void)luaui_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation;
@end

@interface MLNUITableView (Internal) <_MLNUIListInternalRefreshProtocol>
@end

@interface MLNUICollectionView (Internal) <_MLNUIListInternalRefreshProtocol>
//- (void)luaui_reloadData;
//- (void)luaui_insertRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated;
//- (void)luaui_deleteRowsAtSection:(NSInteger)section startRow:(NSInteger)startRow endRow:(NSInteger)endRow animated:(BOOL)animated;
//- (void)luaui_reloadAtRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation;
@end

typedef BOOL(^ActionBlock)(void);

@interface ArgoListViewObserver ()
@property (nonatomic, strong, readwrite) UIView *listView;
@property (nonatomic, strong) NSMutableArray <ActionBlock> *actions;
@property (nonatomic, weak) UIViewController<ArgoViewControllerProtocol> *kitViewController;
@end

@implementation ArgoListViewObserver

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath callback:(ArgoBlockChange)callback {
    if ([listView isKindOfClass:[MLNUITableView class]] || [listView isKindOfClass:[MLNUICollectionView class]]) {
        MLNUITableView *table = (MLNUITableView *)listView;
        UIViewController <ArgoViewControllerProtocol> *kitViewController = (UIViewController<ArgoViewControllerProtocol> *)MLNUI_KIT_INSTANCE([table mlnui_luaCore]).viewController;
        ArgoListViewObserver *observer = [[ArgoListViewObserver alloc] initWithViewController:kitViewController callback:callback keyPath:keyPath];
        observer.listView = listView;
        observer.kitViewController = kitViewController;
        return observer;
    }
    assert(false);
}

- (instancetype)initWithViewController:(UIViewController<ArgoViewControllerProtocol> *)viewController callback:(ArgoBlockChange)callback keyPath:(NSString *)keyPath {
    if (self = [super initWithViewController:viewController callback:callback keyPath:keyPath]) {
        self.actions = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doAction:) name:kUpdateNotiKey object:nil];

    }
    return self;
}

- (void)_doAction:(NSNotification *)noti {
    ActionBlock action = noti.userInfo[@"action"];
    if (action) {
        action();
    }
}

- (void)mergeAction {
    NSArray <ActionBlock>*blocks = self.actions.copy;
    [self.actions removeAllObjects];
    dispatch_block_t doActions = ^{
        DLog(@">>>> do actions count %zd",blocks.count);
        [blocks enumerateObjectsUsingBlock:^(ActionBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            *stop = obj();
        }];
    };
    
//    doActions();return;
    MLNUITableView *list = (MLNUITableView *)self.listView;
    if ([list isKindOfClass:[MLNUITableView class]]) {
        UITableView *table = list.adapter.targetTableView;
        if (@available(iOS 11, *)) {
            [table performBatchUpdates:doActions completion:nil];
        } else {
            [table beginUpdates];
            doActions();
            [table endUpdates];
        }
    } else if([list isKindOfClass:[MLNUICollectionView class]]) {
        MLNUICollectionView *mlncol = (MLNUICollectionView *)list;
        UICollectionView *collection = mlncol.adapter.collectionView;
        [collection performBatchUpdates:doActions completion:nil];
    }
}

- (void)listViewReload:(UIView *)list {
    DLog(@">>>>>  reload");
    MLNUITableView *table = (MLNUITableView *)list;
    SEL sel = @selector(luaui_reloadData);
    if ([table respondsToSelector:sel]) {
        [table luaui_reloadData];
    }
}

- (void)listView:(UIView *)list reloadAtRow:(NSUInteger)row section:(NSUInteger)section {
    DLog(@">>>>>  reload section %zd row %zd",section,row);

    MLNUITableView *table = (MLNUITableView *)list;
    SEL sel = @selector(luaui_reloadAtRow:section:animation:);
    if ([table respondsToSelector:sel]) { // + 1 模拟lua层调用
        [table luaui_reloadAtRow:row + 1 section:section + 1 animation:NO];
    }
}

- (void)listView:(UIView *)list insertRowsAtSection:(NSUInteger)section startRow:(NSUInteger)startRow endRow:(NSUInteger)endRow object:(NSObject *)object {
    DLog(@">>>>>  insert section %zd start_row %zd end_row %zd",section,startRow,endRow);

    MLNUITableView *table = (MLNUITableView *)list;
    SEL sel = @selector(luaui_insertRowsAtSection:startRow:endRow:animated:);
    if ([table respondsToSelector:sel]) { // + 1 模拟lua层调用
        [table luaui_insertRowsAtSection:section + 1 startRow:startRow + 1 endRow:endRow + 1 animated:NO];
    }
}

- (void)listView:(UIView *)list deleteRowsAtSection:(NSUInteger)section startRow:(NSUInteger)startRow endRow:(NSUInteger)endRow object:(NSObject *)object {
    DLog(@">>>>>  delete section %zd start_row %zd end_row %zd",section,startRow,endRow);

    MLNUITableView *table = (MLNUITableView *)list;
    SEL sel = @selector(luaui_deleteRowsAtSection:startRow:endRow:animated:);
    if ([table respondsToSelector:sel]) { // + 1 模拟lua层调用
        [table luaui_deleteRowsAtSection:section + 1 startRow:startRow + 1 endRow:endRow + 1 animated:NO];
    }
}

- (void)mainthread_receiveKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change {
    ActionBlock action;
    @weakify(self);

    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    if (type == NSKeyValueChangeSetting) { //赋值操作
        action = ^BOOL {
            @strongify(self);
            if (!self) {
                return YES;
            }
            [self listViewReload:self.listView];
            return YES;
        };
    } else {
//        id<ArgoObserverProtocol> array = [change objectForKey:kArgoListenerChangedObject];
        action = ^BOOL { //参考MLNUIListViewObserver，由于子模块的传参问题，只能reload
            @strongify(self);
            if (!self) {
                return YES;
            }
            [self listViewReload:self.listView];
            return YES;
        };
    }
    
    action();
//    NSNotification *noti = [NSNotification notificationWithName:kUpdateNotiKey object:nil userInfo:@{@"action" : action}];
//    [[NSNotificationQueue defaultQueue] enqueueNotification:noti postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:@[NSRunLoopCommonModes]];
}

- (void)receiveKeyPath:(NSString *)keyPath ofObject:(id<ArgoListenerProtocol>)object change:(NSDictionary *)change {
    if ([NSThread isMainThread]) {
        [super receiveKeyPath:keyPath ofObject:object change:change];
        [self mainthread_receiveKeyPath:keyPath ofObject:object change:change];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [super receiveKeyPath:keyPath ofObject:object change:change];
            [self mainthread_receiveKeyPath:keyPath ofObject:object change:change];
        });
    }
}


//- (void)_mainThreadNotifyKeyPath:(NSString *)keyPath ofObject:(NSArray *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
//
////    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(mergeAction) object:nil];
////    [self performSelector:@selector(mergeAction) withObject:nil afterDelay:0];
////    DLog(@"keypath %@, object %@ change %@",keyPath, object, change);
//    NSObject *new = [change objectForKey:NSKeyValueChangeNewKey];
//    NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
//    BOOL indexSetCount = [indexSet count];
//
//    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
//    if (type == NSKeyValueChangeSetting || ((type == NSKeyValueChangeInsertion || type == NSKeyValueChangeReplacement) && indexSetCount == 1)) {
//        if ([new isKindOfClass:[NSMutableArray class]]) {
////            [self.viewController.mlnui_dataBinding addMLNUIObserver:self forKeyPath:self.keyPath];
//            @weakify(self);
//            [self mlnui_observeArray:(NSMutableArray *)new withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//                @strongify(self);
//                //[self mlnui_observeValueForKeyPath:nil ofObject:object change:change];
//            }];
//            [new mlnui_addDeallocationCallback:^(id  _Nonnull receiver) {
//                [receiver mlnui_removeAllObservations];
//            }];
//        }
//    }
//
//    ActionBlock action;
//    @weakify(self);
//#if 1
//    if (type == NSKeyValueChangeSetting || YES) // FIXME: 新增数据时，如果不reload，lua层子模块的序号不会改变，导致使用了错误的key值
//#else
//    if (type == NSKeyValueChangeSetting)
//#endif
//    {
//        action = ^BOOL {
//            @strongify(self);
//            if (!self) {
//                return YES;
//            }
//            [self listViewReload:self.listView];
//            return YES;
//        };
//    }
//    else
//    {
//        NSParameterAssert([object isKindOfClass:[NSArray class]]);
//        NSObject *old = [change objectForKey:NSKeyValueChangeOldKey];
//        NSObject *tmp = new ? new : old;
//
//        action = ^BOOL{
//            if (!self) {
//                return YES;
//            }
//
//            NSUInteger section = 0;
//            NSUInteger startRow = indexSet.firstIndex;
//            NSUInteger endRow = indexSet.firstIndex;
//
//            if ([tmp isKindOfClass:[NSArray class]]) { //insert section，没有桥接，使用的应该不多
//                section = indexSet.firstIndex;
//                [self listViewReload:self.listView];
//                return YES;
//            } else if([object mlnui_is2D]  && tmp) {  //ex. object[0][0] = xx
//                section = [object indexOfObject:tmp];
//            }
//            switch (type) {
//        //        case NSKeyValueChangeSetting:
//        //            break;
//                case NSKeyValueChangeInsertion: {
//                    [self listView:self.listView insertRowsAtSection:section startRow:startRow endRow:endRow object:tmp];
//                }
//                    break;
//                case NSKeyValueChangeRemoval: {
//                    [self listView:self.listView deleteRowsAtSection:section startRow:startRow endRow:endRow object:tmp];
//                }
//                    break;
//                case NSKeyValueChangeReplacement:
//                    [self listView:self.listView reloadAtRow:startRow section:section];
//                    break;
//                default:
//                    [self listViewReload:self.listView];
//                    return YES;
//                    break;
//            }
//            return NO;
//        };
//    }
//
////    action();
////    [self.class cancelPreviousPerformRequestsWithTarget:self];
////    [self performSelector:@selector(_doAction:) withObject:action afterDelay:0];
//
//    NSNotification *noti = [NSNotification notificationWithName:kUpdateNotiKey object:nil userInfo:@{@"action" : action}];
//    [[NSNotificationQueue defaultQueue] enqueueNotification:noti postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:@[NSRunLoopCommonModes]];
//}
@end
