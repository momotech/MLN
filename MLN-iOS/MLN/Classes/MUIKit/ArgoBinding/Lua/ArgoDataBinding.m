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
#import "MLNUILuaTable.h"
#import "NSObject+ArgoListener.h"
#import "MLNUIHeader.h"

@interface _ArgoBindCellInternalModel : NSObject
//@property (nonatomic, strong) NSMutableDictionary *pathMap;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, assign) NSInteger tokenID;
@end
@implementation _ArgoBindCellInternalModel
- (instancetype)init{
    self = [super init];
    if (self) {
//        _pathMap = [NSMutableDictionary dictionary];
    }
    return self;
}
@end

@interface _ArgoBindListViewInternalModel : NSObject
@property (nonatomic, weak) UIView *listView;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, assign) NSInteger tokenID;
@end

@implementation _ArgoBindListViewInternalModel
@end

@interface ArgoDataBinding () {
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) ArgoObservableMap *dataMap;
@property (nonatomic, strong) NSMutableDictionary *observerMap;
@property (nonatomic, strong) NSMapTable <NSString *, _ArgoBindListViewInternalModel* > *listViewMap;
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

- (void)bindData:(nullable NSObject<ArgoListenerProtocol> *)data forKey:(NSString *)key {
    NSParameterAssert(key);
    if (key) {
        LOCK();
//        [self.dataMap lua_putValue:data forKey:key];
        [self.dataMap native_putValue:data forKey:key];
//        [self.dataMap lua_rawPutValue:data forKey:key];
        UNLOCK();
    }
}

- (void)bindData:(nonnull NSObject<ArgoListenerProtocol> *)data {
    SEL sel = sel_registerName("modelKey");
    NSAssert([data.class respondsToSelector:sel], @"Data必须实现方法：modelKey ");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *key = [data.class performSelector:sel];
#pragma clang diagnostic pop
    [self bindData:data forKey:key];
}

- (void)unbindData:(NSObject<ArgoListenerProtocol> *)data {
    SEL sel = sel_registerName("modelKey");
    NSAssert([data.class respondsToSelector:sel], @"Data必须实现方法：modelKey ");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *key = [data.class performSelector:sel];
#pragma clang diagnostic pop
    [self bindData:nil forKey:key];
}

- (id)dataForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    if(!keyPath) return nil;
    return [self.dataMap argoGetForKeyPath:keyPath];
}

- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value context:(ArgoWatchContext)context {
    NSParameterAssert(keyPath);
    if(!keyPath) return;
    NSArray *keys = [keyPath componentsSeparatedByString:kArgoConstString_Dot];
    NSObject<ArgoListenerProtocol> *object = self.dataMap;
    NSObject<ArgoListenerProtocol> *frontObject;
    BOOL detected = NO;
    
    for (int i = 0; i < keys.count - 1; i++) {
        //TODO: 对于Map，如果中间对象为空，默认创建.
        frontObject = object;
        object = (NSObject<ArgoListenerProtocol> *)[frontObject lua_get:keys[i]];
        if (!object && !detected) {
            detected = YES;
            if ([ArgoObserverHelper hasNumberInKeys:keys fromIndex:i]) {
                break;
            }
        }
        if (!object) {
            /*
             object = [ArgoObservableMap new];
            //TODO: 不能使用lua_rawPutValue，ex：watch(a.b.c), b=nil; 对c的监听要添加到b对象上并进行依次传递，所以不能用lua_rawPutValue
            [frontObject lua_putValue:object forKey:keys[i]];
             */
            if (ArgoWatchContext_Lua == context) {
                NSObject<ArgoListenerProtocol> *tmpObj = [ArgoObservableMap new];
                NSString *tmpKey = keys[i];
                object = tmpObj;
                for (int j = i + 1; j < keys.count - 1; j++) {
                    NSObject<ArgoListenerProtocol> *obj = [ArgoObservableMap new];
                    [object lua_rawPutValue:obj forKey:keys[j]];
                    object = obj;
                }
                //设置最后一个值，需要触发粘性
                [object lua_putValue:value forKey:keys.lastObject];
                object = nil;
                [frontObject lua_putValue:tmpObj forKey:tmpKey];
            } else {
                NSObject<ArgoListenerProtocol> *tmpObj = [ArgoObservableMap new];
                NSString *tmpKey = keys[i];
                object = tmpObj;
                for (int j = i + 1; j < keys.count - 1; j++) {
                    NSObject<ArgoListenerProtocol> *obj = [ArgoObservableMap new];
                    [object native_rawPutValue:obj forKey:keys[j]];
                    object = obj;
                }
                //设置最后一个值，需要触发粘性
                [object native_putValue:value forKey:keys.lastObject];
                object = nil;
                [frontObject native_putValue:tmpObj forKey:tmpKey];
            }
            break;
        }
    }
    
    if (ArgoWatchContext_Lua == context) {
        [object lua_putValue:value forKey:keys.lastObject];
    } else {
        [object native_putValue:value forKey:keys.lastObject];
    }
}

#pragma mark - for Lua


- (id __nullable)argo_get:(NSString *)keyPath {
    if(!keyPath) return nil;
    NSString *newKeyPath = [self convertedKeyPathWith:keyPath];
    return [self dataForKeyPath:newKeyPath];
}

- (void)argo_updateValue:(id)value forKeyPath:(NSString *)keyPath {
    if(!keyPath) return;
    keyPath = [self convertedKeyPathWith:keyPath];
    [self updateDataForKeyPath:keyPath value:value context:ArgoWatchContext_Lua];
}

// from watch
- (NSInteger)argo_watchKeyPath:(NSString *)keyPath withHandler:(MLNUIBlock *)handler filter:(MLNUIBlock *)filter {
    return [self _watchKeyPath:keyPath handler:handler listView:nil filter:filter == nil ? kArgoFilter_Native : ^BOOL(ArgoWatchContext context, NSDictionary *change) {
        [filter addUIntegerArgument:context];
        NSUInteger count = [[change objectForKey:kArgoListenerCallCountKey] unsignedIntegerValue];
        [filter addUIntegerArgument:count];
        
        id res = [filter callIfCan];
        return [res boolValue];
    } triggerWhenAdd:NO];
}

- (NSInteger)argo_watchKeyPath2:(NSString *)keyPath withHandler:(MLNUIBlock *)handler filter:(MLNUIBlock *)filter {
    return [self _watchKeyPath:keyPath handler:handler listView:nil filter:filter == nil ? nil : ^BOOL(ArgoWatchContext context, NSDictionary *change) {
        [filter addUIntegerArgument:context];
        NSUInteger count = [[change objectForKey:kArgoListenerCallCountKey] unsignedIntegerValue];
        [filter addUIntegerArgument:count];
        
        id res = [filter callIfCan];
        return [res boolValue];
    } triggerWhenAdd:NO];
}

- (NSInteger)argo_watchKey:(NSString *)key withHandler:(MLNUIBlock *)handler filter:(MLNUIBlock *)filter {
    return [self _watchKeyPath:key handler:handler listView:nil filter:filter == nil ? ^BOOL(ArgoWatchContext context, NSDictionary *change) {
        // 默认只监听native
        if (context == ArgoWatchContext_Lua) {
            return NO;
        }
        return kArgoWatchKeyListenerFilter(context, change);
    } : ^BOOL(ArgoWatchContext context, NSDictionary *change) {
        BOOL r = kArgoWatchKeyListenerFilter(context, change);
        if (r) {
            [filter addUIntegerArgument:context];
            NSUInteger count = [[change objectForKey:kArgoListenerCallCountKey] unsignedIntegerValue];
            [filter addUIntegerArgument:count];
            
            id res = [filter callIfCan];
            r &= [res boolValue];
        }
        return r;
    } triggerWhenAdd:NO];
}

- (NSInteger)_watchKeyPath:(NSString *)keyPath handler:(MLNUIBlock *)handler listView:(UIView *)listView filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd {
    NSArray *keys = [keyPath componentsSeparatedByString:kArgoConstString_Dot];
    NSInteger lastNumberIndex = [ArgoObserverHelper lastNumberIndexOf:keys];
    if (lastNumberIndex == NSNotFound) { //没有数字
        return [self _observeObject:self.dataMap keyPath:keyPath handler:handler listView:listView filter:filter triggerWhenAdd:triggerWhenAdd];
    }
    
    if (lastNumberIndex == keys.count - 1) { //最后一位是数字!
        NSString *log = [NSString stringWithFormat:@"%s，%@: 最后一个path不能是数字",__func__, keyPath];
        [self doErrorLog:log];
        return NSNotFound;
    }
    //keyPath:a.b.1.d.e, befor:a.b.1 after:d.e
    NSString *befor = [ArgoObserverHelper stringBefor:lastNumberIndex withKeys:keys];
    NSString *after = [keyPath substringFromIndex:befor.length + 1];
    id<ArgoListenerProtocol> observed = [self argo_get:befor];
    if (!observed) {
        return NSNotFound;
    }
    return [self _observeObject:observed keyPath:after handler:handler listView:listView filter:filter triggerWhenAdd:triggerWhenAdd];
}

- (NSInteger)_observeObject:(id<ArgoListenerProtocol>)observed keyPath:(NSString *)keyPath handler:(MLNUIBlock *)handler listView:(UIView *)listView filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd{
    ArgoObserverBase *observer;
    if (handler) {
        observer = [ArgoLuaObserver observerWithBlock:handler callback:nil keyPath:keyPath];
    } else if(listView) {
        observer = [ArgoListViewObserver observerWithListView:listView keyPath:keyPath callback:nil];
    }
    return [self _addOberver:observer forObject:observed filter:filter triggerWhenAdd:triggerWhenAdd];
}

- (NSInteger)_addOberver:(ArgoObserverBase *)observer forObject:(id<ArgoListenerProtocol>)observed filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd {
    id<ArgoListenerToken> token = [observed addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        [observer notifyKeyPath:keyPath ofObject:object change:change];
    } forKeyPath:observer.keyPath filter:filter triggerWhenAdd:triggerWhenAdd];
    [self.observerMap setObject:token forKey:@(token.tokenID)];
    return token.tokenID;
}

- (void)argo_unwatch:(NSInteger)tokenID {
    NSObject <ArgoListenerToken> *token = [self.observerMap objectForKey:@(tokenID)];
    if (token) {
        PLOG(@"_argo_ unwatch %@ id %zd",[token performSelector:NSSelectorFromString(@"keyPath")], token.tokenID);
        [token removeListener];
        [self.observerMap removeObjectForKey:@(tokenID)];
    }
}

- (NSInteger)argo_bindListView:(UIView *)listView forTag:(NSString *)tag {
    if(!listView || !tag) return NSNotFound;
    _ArgoBindListViewInternalModel *model = [self.listViewMap objectForKey:tag];
    if (listView == model.listView) {
        PLOG(@">>>>>> list view %@ already add observer",listView);
        return model.tokenID;
    }
    if (model) { //移除监听
        [self.listViewMap removeObjectForKey:tag];
        [self argo_unwatch:model.tokenID];
    }
    model = [_ArgoBindListViewInternalModel new];
//    [self.listViewMap setObject:listView forKey:tag];
    //TODO: 需要转换？
    tag = [self convertedKeyPathWith:tag];
    PLOG(@"_argo_ bind listview %@ %p",tag, listView);
    NSInteger tokenID = [self _watchKeyPath:tag handler:nil listView:listView filter:nil triggerWhenAdd:NO];
    model.listView = listView;
    model.tokenID = tokenID;
    model.keyPath = tag;
    [self.listViewMap setObject:model forKey:tag];
    return tokenID;
}

- (UIView *)argo_listViewForTag:(NSString *)tag {
    if (!tag) {
        return nil;
    }
    return [[self.listViewMap objectForKey:tag] listView];
}

static inline ArgoObserverBase *_getArgoObserver(UIViewController <ArgoViewControllerProtocol> *kitViewController, UIView *listView, NSString *nk, NSString *idKey) {
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

//#   define TICK2() CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent()
//#   define TOCK2(name, name2) printf(">>>>>> %s  %s took time: %.2f ms \n",name,name2, (CFAbsoluteTimeGetCurrent() - startTime) * 1000); startTime = CFAbsoluteTimeGetCurrent()
//
//#   define TICK3() CFAbsoluteTime startTime2 = CFAbsoluteTimeGetCurrent()
//#   define TOCK3(name, name2) printf(">>>>>> %s  %s took time: %.2f ms \n",name,name2, (CFAbsoluteTimeGetCurrent() - startTime2) * 1000); startTime2 = CFAbsoluteTimeGetCurrent()

#define TICK2()
#define TOCK2(name,name2)
#define TICK3()
#define TOCK3(name,name2)

- (void)argo_bindCellWithController:(UIViewController <ArgoViewControllerProtocol> *)viewController KeyPath:(NSString *)keyPath section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths {
    UIView *listView = [self argo_listViewForTag:keyPath];
    if (!listView)  return;
    TICK2();
    
    NSMutableDictionary *infos = [listView mlnui_bindInfos];
    id<ArgoListenerProtocol> cellModel;
    ArgoObservableArray *listArray = [self argo_get:keyPath];
    
    TOCK2("get ", keyPath.UTF8String);
    
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
    if (model.paths.count == paths.count) {
        return;
    }
    if (model.paths.count > 0) {
        [self argo_unwatch:model.tokenID];
    }
    
//    NSMutableArray *newPaths = paths.mutableCopy;
//    [newPaths removeObjectsInArray:model.pathMap.allKeys];
    TOCK2("handle ", "");
    TICK3();
//    for (NSString *p in newPaths) {
//        ArgoObserverBase *ob = _getArgoObserver(viewController, listView, p, idKey);
//        NSInteger obid = [self _addOberver:ob forObject:cellModel];
//        [model.pathMap setObject:@(obid) forKey:p];
//        TOCK2("add observer", p.UTF8String);
//    }
    
    PLOG(@"_argo_ bind cell paths %@",paths);
    
    ArgoObserverBase *observer = _getArgoObserver(viewController, listView, @"", idKey);
//    id<ArgoListenerToken> token = [cellModel addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
//        [observer notifyKeyPath:keyPath ofObject:object change:change];
//    } forKeyPath:observer.keyPath];
    id<ArgoListenerToken> token = [cellModel addArgoListenerWithChangeBlockForAllKeys:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        [observer notifyKeyPath:keyPath ofObject:object change:change];
    } filter:nil keyPaths:paths triggerWhenAdd:NO];
    
    [self.observerMap setObject:token forKey:@(token.tokenID)];
    model.paths = paths;
    model.tokenID = token.tokenID;
    TOCK3("add observer ", [@(newPaths.count).stringValue UTF8String]);
}

- (MLNUILuaTable *)luaTableOf:(id<ArgoObserverProtocol>)object {
    return nil;
}

#pragma mark - Utils

- (NSString *)listViewKeyMatch:(NSString *)tag {
    NSString *lvKey;
    NSArray *keys = [self.listViewMap.keyEnumerator.allObjects sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
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
    return [self _recursiveConvertedKeyPathWith:key resolvedListViewTag:nil];
    /*
    _ArgoBindListViewInternalModel *listModel = [self.listViewMap objectForKey:key];
    if (listModel) {
        return key;
    }
    NSString *lvKey = [self listViewKeyMatch:key];
    if (!lvKey) {
        return key;
    }
//    if ([key isEqualToString:lvKey]) {
//        return key;
//    }
    NSString *rest = [key substringFromIndex:lvKey.length + 1];
    NSArray *restKeys = [rest componentsSeparatedByString:kArgoConstString_Dot];
    
    ArgoObservableArray *array = [self dataForKeyPath:lvKey];
    if (![ArgoObserverHelper arrayIs2D:array] && restKeys.count > 1 && [ArgoObserverHelper isNumber:restKeys[1]]) {
        //一维数组且第二位是数字，去掉第一位
        NSRange range = [rest rangeOfString:kArgoConstString_Dot];
        NSString *newK = [lvKey stringByAppendingString:[rest substringFromIndex:range.location]];
        return newK;
    }
    return key;
     */
}

- (NSString *)_recursiveConvertedKeyPathWith:(NSString *)key resolvedListViewTag:(NSString *)resolvedTag {
    _ArgoBindListViewInternalModel *listModel = [self.listViewMap objectForKey:key];
    if (listModel) {
        return key;
    }
    NSString *lvKey = [self listViewKeyMatch:key];
    if (!lvKey || (resolvedTag && [resolvedTag isEqualToString:lvKey])) {
        return key;
    }
    NSString *rest = [key substringFromIndex:lvKey.length + 1];
    NSArray *restKeys = [rest componentsSeparatedByString:kArgoConstString_Dot];
    
    ArgoObservableArray *array = [self dataForKeyPath:lvKey];
    if (![ArgoObserverHelper arrayIs2D:array] && restKeys.count > 1 && [ArgoObserverHelper isNumber:restKeys[1]]) {
        //一维数组且第二位是数字，去掉第一位
        NSRange range = [rest rangeOfString:kArgoConstString_Dot];
        NSString *newK = [lvKey stringByAppendingString:[rest substringFromIndex:range.location]];
        return [self _recursiveConvertedKeyPathWith:newK resolvedListViewTag:lvKey];
    }
    return key;
}

#pragma mark -
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataMap = [ArgoObservableMap dictionary];
        self.observerMap = [NSMutableDictionary dictionary];
        self.listViewMap = [NSMapTable strongToStrongObjectsMapTable];
//        self.listViewMap = [NSMutableDictionary dictionary];
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
