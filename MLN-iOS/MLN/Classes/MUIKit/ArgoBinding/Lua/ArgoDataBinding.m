//
//  ArgoDataBinding.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#import "ArgoDataBinding.h"
#import <pthread.h>
#import "MLNUIExtScope.h"
#import "NSObject+MLNUIDealloctor.h"
#import "MLNUIExtScope.h"
#import "MLNUIKVOObserverProtocol.h"

#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "ArgoObserverHelper.h"
#import "ArgoLuaObserver.h"
#import "ArgoListViewObserver.h"

#import "NSObject+MLNUIReflect.h"
#import "MLNUITableView.h"
#import "MLNUICollectionView.h"

@interface _ArgoBindCellInternalModel : NSObject
@property (nonatomic, strong) NSMutableDictionary *pathMap;
@property (nonatomic, strong) NSIndexPath *indexPath;
//@property (nonatomic, strong) NSMutableArray *paths;
@end
@implementation _ArgoBindCellInternalModel @end


@interface ArgoDataBinding () {
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) ArgoObservableMap *dataMap;
@property (nonatomic, strong) NSMutableDictionary *observerMap;
@property (nonatomic, strong) NSMutableDictionary *listViewMap;
@end

@interface ArgoInternalListViewPairs : NSObject
@property (nonatomic, weak) UIView *listView;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) BOOL dataSourceIs2D;
@end
@implementation ArgoInternalListViewPairs
@end

@implementation ArgoDataBinding

#pragma mark - Public

- (void)bindData:(nullable id<ArgoListenerProtocol>)data forKey:(NSString *)key {
    NSParameterAssert(key);
    if (key) {
        LOCK();
        [self.dataMap putValue:data forKey:key];
        UNLOCK();
    }
}

- (void)bindData:(nullable id<ArgoListenerProtocol>)data {
    SEL sel = sel_registerName("modelKey");
    NSAssert([data.class respondsToSelector:sel], @"Data必须实现方法：modelKey ");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *key = [data.class performSelector:sel];
#pragma clang diagnostic pop
    [self bindData:data forKey:key];
}

- (id)dataForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    if(!keyPath) return nil;
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    id<ArgoListenerProtocol> object = self.dataMap;
    for (NSString *key in keys) {
        object = (id <ArgoListenerProtocol>)[object get:key];
    }
    return object;
}

- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value {
    NSParameterAssert(keyPath);
    if(!keyPath) return;
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    id<ArgoListenerProtocol> object = self.dataMap;
    for (int i = 0; i < keys.count - 1; i++) {
        //TODO: 对于Map，如果中间对象为空，默认创建.
        object = (id<ArgoListenerProtocol>)[object get:keys[i]];
    }
    [object putValue:value forKey:keys.lastObject];
}

#pragma mark - for Lua


- (id __nullable)argo_get:(NSString *)keyPath {
    if(!keyPath) return nil;
    keyPath = [self convertedKeyPathWith:keyPath];
    return [self dataForKeyPath:keyPath];
}

- (void)argo_updateValue:(id)value forKeyPath:(NSString *)keyPath {
    if(!keyPath) return;
    keyPath = [self convertedKeyPathWith:keyPath];
    [self updateDataForKeyPath:keyPath value:value];
}

// from watch
- (NSInteger)argo_watchKeyPath:(NSString *)keyPath withHandler:(MLNUIBlock *)handler {
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    NSInteger lastNumberIndex = [ArgoObserverHelper lastNumberIndexOf:keys];
    if (lastNumberIndex == NSNotFound) { //没有数字
        return [self _observeObject:self.dataMap keyPath:keyPath handler:handler listView:nil];
    }
    
    if (lastNumberIndex == keys.count - 1) { //最后一位是数字!
        NSString *log = [NSString stringWithFormat:@"%s，%@: 最后一个path不能是数字",__func__, keyPath];
        [self doErrorLog:log];
        return NSIntegerMax;
    }
    //keyPath:a.b.1.d.e, befor:a.b.1 after:d.e
    NSString *befor = [ArgoObserverHelper stringBefor:lastNumberIndex withKeys:keys];
    NSString *after = [keyPath substringFromIndex:befor.length + 1];
    id<ArgoListenerProtocol> observed = [self argo_get:befor];
    return [self _observeObject:observed keyPath:after handler:handler listView:nil];
}

- (NSInteger)_observeObject:(id<ArgoListenerProtocol>)observed keyPath:(NSString *)keyPath handler:(MLNUIBlock *)handler listView:(UIView *)listView {
    ArgoObserverBase *observer;
    if (handler) {
        observer = [ArgoLuaObserver observerWithBlock:handler callback:nil keyPath:keyPath];
    } else if(listView) {
        observer = [ArgoListViewObserver observerWithListView:listView keyPath:keyPath callback:nil];
    }
    return [self _addOberver:observer forObject:observed];
}

- (NSInteger)_addOberver:(ArgoObserverBase *)observer forObject:(id<ArgoListenerProtocol>)observed {
    id<ArgoListenerToken> token = [observed addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        [observer notifyKeyPath:keyPath ofObject:object change:change];
    } forKeyPath:observer.keyPath];
    [self.observerMap setObject:token forKey:@(token.tokenID)];
    return token.tokenID;
}

- (void)argo_unwatch:(NSInteger)tokenID {
    id<ArgoListenerToken> token = [self.observerMap objectForKey:@(tokenID)];
    if (token) {
        [token removeListener];
        [self.observerMap removeObjectForKey:@(tokenID)];
    }
}

- (void)argo_bindListView:(UIView *)listView forTag:(NSString *)tag {
    if(!listView || !tag) return;
    [self.listViewMap setObject:listView forKey:tag];
    //TODO: 需要转换？
    tag = [self convertedKeyPathWith:tag];
    [self _observeObject:self.dataMap keyPath:tag handler:nil listView:listView];
}

- (UIView *)argo_listViewForTag:(NSString *)tag {
    if (!tag) {
        return nil;
    }
    return [self.listViewMap objectForKey:tag];
}

static inline ArgoObserverBase *_getArgoObserver(UIViewController *kitViewController, UIView *listView, NSString *nk, NSString *idKey) {
    ArgoObserverBase *ob = [[ArgoObserverBase alloc] initWithViewController:kitViewController callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        if ([listView isKindOfClass:[MLNUITableView class]]) {
            MLNUITableView *table = (MLNUITableView *)listView;
            NSIndexPath *indexPath = [[[listView mlnui_bindInfos] objectForKey:idKey] indexPath];
            
            [table.adapter tableView:table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath]];
            [table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } else if([listView isKindOfClass:[MLNUICollectionView class]]){
            MLNUICollectionView *collection = (MLNUICollectionView *)listView;
            NSIndexPath *indexPath = [[[listView mlnui_bindInfos] objectForKey:idKey] indexPath];
            
            [collection.adapter collectionView:collection.adapter.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [collection.adapter.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    } keyPath:nk];
    return ob;
}

- (void)argo_bindCellWithController:(UIViewController *)viewController KeyPath:(NSString *)keyPath section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths {
    UIView *listView = [self argo_listViewForTag:keyPath];
    if (!listView)  return;

    NSMutableDictionary *infos = [listView mlnui_bindInfos];
    id<ArgoListenerProtocol> cellModel;
    ArgoObservableArray *listArray = [self argo_get:keyPath];
    if ([ArgoObserverHelper arrayIs2D:listArray]) {
        NSArray *tmp = section <= listArray.count ? listArray[section - 1] : nil;
        cellModel = row <= tmp.count ? tmp[row - 1] : nil;
    } else {
        cellModel = listArray[row - 1];
    }
    
    NSString *idKey = [keyPath stringByAppendingFormat:@".%p",cellModel];
    _ArgoBindCellInternalModel *model = [infos objectForKey:idKey];
    if (!model) {
        model = [_ArgoBindCellInternalModel new];
        [infos setObject:model forKey:idKey];
    }
    
    NSIndexPath *ip = model.indexPath;
    if (!ip || ip.section != (section - 1) || ip.row != (row - 1)) {
        model.indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];
    }
    
    NSMutableArray *newPaths = paths.mutableCopy;
    [newPaths removeObjectsInArray:model.pathMap.allKeys];
    
    for (NSString *p in newPaths) {
        ArgoObserverBase *ob = _getArgoObserver(viewController, listView, p, idKey);
        NSInteger obid = [self _addOberver:ob forObject:cellModel];
        [model.pathMap setObject:@(obid) forKey:p];
    }
}
#pragma mark - Utils

- (NSString *)listViewKeyMatch:(NSString *)tag {
    NSString *lvKey;
    NSArray *keys = [self.listViewMap.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        return (obj1.length > obj2.length) ? NSOrderedAscending : NSOrderedDescending;
    }];
    for (NSString *k in keys) {
        if ([tag hasPrefix:k]) {
            lvKey = k;
            break;
        }
    }
    return lvKey;
}

- (NSString *)convertedKeyPathWith:(NSString *)key {
    NSString *lvKey = [self listViewKeyMatch:key];
    if (!lvKey) {
        return key;
    }
    if ([key isEqualToString:lvKey]) {
        return key;
    }
    NSString *rest = [key substringFromIndex:lvKey.length + 1];
    NSArray *restKeys = [rest componentsSeparatedByString:@"."];
    
    ArgoObservableArray *array = [self dataForKeyPath:lvKey];
    if (![ArgoObserverHelper arrayIs2D:array] && restKeys.count > 1 && [ArgoObserverHelper isNumber:restKeys[1]]) {
        //一维数组且第二位是数字，去掉第一位
        NSRange range = [rest rangeOfString:@"."];
        NSString *newK = [lvKey stringByAppendingString:[rest substringFromIndex:range.location]];
        return newK;
    }
    return key;
}

#pragma mark -
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataMap = [ArgoObservableMap dictionary];
        self.observerMap = [NSMutableDictionary dictionary];
//        self.listViewMap = [NSMapTable strongToWeakObjectsMapTable];
        self.listViewMap = [NSMutableDictionary dictionary];
        LOCK_RECURSIVE_INIT();
    }
    return self;
}

- (void)dealloc {
    LOCK_DESTROY();
}

- (void)doErrorLog:(NSString *)log{
    NSLog(@"%@",log);
    if(self.errorLog) self.errorLog(log);
}

@end
