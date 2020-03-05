//
//  MLNListViewObserver.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "MLNListViewObserver.h"
#import "MLNTableView.h"
#import "MLNKitViewController.h"
#import "MLNKitHeader.h"

@interface MLNListViewObserver ()
@property (nonatomic, strong, readwrite) UIView *listView;
@end

@implementation MLNListViewObserver

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath {
    
    if ([listView isKindOfClass:[MLNTableView class]]) {
        MLNTableView *table = (MLNTableView *)listView;
        
        MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([table mln_luaCore]).viewController;
        MLNListViewObserver *observer = [[MLNListViewObserver alloc] initWithViewController:kitViewController callback:nil keyPath:keyPath];
        observer.listView = listView;
        return observer;
    }
    assert(false);
}

- (void)notifyKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    [super notifyKeyPath:keyPath ofObject:object change:change];
    [(UITableView *)self.listView reloadData];
    
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

@end
