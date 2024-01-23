//
//  MDListWhiteDetector.m
//  MLN
//
//  Created by xue.yunqiang on 2022/3/2.
//

#import "MDListWhiteDetector.h"
#import "MLNListDetectItem.h"
#import "MLNLayoutNode.h"
#import "MLNTableView.h"
#import "MLNCollectionView.h"
#import "MLNWindow.h"
#import "MLNInnerTableView.h"
#import "MLNInnerCollectionView.h"
#import "MLNKitInstance.h"

@interface MDListWhiteDetector()

@property(nonatomic, strong) MLNListDetectItem *item;

@property (nonatomic, strong) MLNLayoutNode *node;

@property (nonatomic, strong) NSTimer *detectWhiteScreenTimer;

@property (nonatomic, assign) BOOL isHasReload;

@property (nonatomic, assign) BOOL isWhite;

@property (nonatomic, assign) BOOL wasWhite;

@property (nonatomic, assign) int detectTime;

@property (nonatomic, assign) BOOL trigerDetect;

@property (nonatomic, assign) NSInteger currentdetectDeep;

@end

@implementation MDListWhiteDetector

#pragma mark - Public Method
- (instancetype)initWithDetectItem:(MLNListDetectItem *) item {
    if (!item) {
        return nil;
    }
    if (self = [super init]) {
        self.item = item;
        self.currentdetectDeep = self.item.detectLayerDeep;
    }
    return self;
}

- (void)start:(MLNLayoutNode *)node {
    self.node = node;
    if (!self.trigerDetect) {
        self.trigerDetect = YES;
        [self innerStart];
    }
}

- (void)stop {
    [_detectWhiteScreenTimer invalidate];
    _detectWhiteScreenTimer = nil;
}

- (void)reload {
    self.isHasReload = YES;
}

#pragma mark - Private Method
- (void)innerStart {
    self.trigerDetect = YES;
    if (@available(iOS 10.0, *)) {
        __weak __typeof(self) weakSelf = self;
        NSTimeInterval interval = self.item.detectTimeInterval;
        _detectWhiteScreenTimer = [NSTimer scheduledTimerWithTimeInterval:interval == 0 ? interval : 5 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [weakSelf detect];
            [timer invalidate];
            timer = nil;
        }];
    }
}

- (void)detect {
    self.detectTime ++;
    if (self.detectTime == 1) {
        //to small
        CGFloat area = CGRectGetWidth(self.item.instance.luaWindow.bounds) * CGRectGetHeight(self.item.instance.luaWindow.bounds);
        if ((self.node.width * self.node.height * 3 < area) &&
            (CGRectGetWidth(self.node.targetView.frame) * CGRectGetHeight(self.node.targetView.frame) * 3 < area) ) {
            return;
        }
        //out of window
        CGRect convertFrame = [self.node.targetView convertRect:self.node.targetView.frame toView:nil];
        if ((CGRectGetMinX(convertFrame) >= CGRectGetWidth(self.node.targetView.window.bounds)) ||
            (CGRectGetMinY(convertFrame) >= CGRectGetHeight(self.node.targetView.window.bounds))) {
            return;
        }
    }
    
    self.isWhite = !self.isHasReload && ![self nodeIsGone];
    // cheak subview
    self.isWhite = self.isWhite ? ![self hasSubView] : self.isWhite;
    if (self.isWhite &&
        !CGRectEqualToRect(CGRectZero, self.node.targetView.bounds) &&
        self.node.rootnode.width != 0) {
        self.isWhite = ![self hasCoverView];
    } else {
        self.isWhite = NO;
    }
    BOOL needLog = (self.detectTime <= self.item.detectTimeLimite) && ((self.detectTime == 1 && self.isWhite) || self.wasWhite);
    if (needLog)  {
        [self.item.logHandle mlnListWhiteDetectLog:[self setupLogInfo]];
        [self innerRestart];
    } else {
        [self stop];
    }
    self.wasWhite = self.isWhite;
}

- (BOOL)hasCoverView {
    //是否有View显示在列表上方，并且View的中心在列表View的中心，宽至少是列表View的1/3
    BOOL hasCoverView = NO;
    if (self.node && self.node.supernode) {
        UIView *targetView = self.node.targetView;
        BOOL needDetect = YES;
        while (needDetect &&
               targetView &&
               !hasCoverView &&
               ![targetView isKindOfClass:[MLNWindow class]] &&
               !CGRectEqualToRect(CGRectZero, targetView.bounds)) {
            self.currentdetectDeep -= 1;
            needDetect = (self.item.detectLayerDeep == 0) ? YES : (self.currentdetectDeep != 0);
            hasCoverView = [self currentLayerHasCover:targetView];
            if (!hasCoverView) {
                targetView = targetView.superview;
            }
        }
    }
    return hasCoverView;
}

- (BOOL)currentLayerHasCover:(UIView *)targetView {
    BOOL hasCoverView = NO;
    //cheak bro
    NSArray *bros = targetView.superview.subviews;
    NSUInteger cIndex = [bros indexOfObject:targetView];
    NSUInteger baseIndex = cIndex + 1;
    NSUInteger shouldDetectCount = (self.item.detectLayerBreadth == 0 || (baseIndex + self.item.detectLayerBreadth) > bros.count) ? (bros.count - baseIndex) : self.item.detectLayerBreadth;
    for (NSUInteger i = baseIndex; i < (baseIndex + shouldDetectCount); i++) {
        UIView *view = [bros objectAtIndex:i];
        if (CGPointEqualToPoint(targetView.center , view.center) &&
            self.node.rootnode.width <= (3 * CGRectGetWidth(view.bounds)) &&
            !view.hidden) {
            hasCoverView = YES;
            break;
        }
    }
    return hasCoverView;
}

- (BOOL)hasSubView {
    NSInteger row = 0;
    BOOL hasSubView = NO;
    if ([self.node.targetView isKindOfClass:[MLNTableView class]]) {
        MLNTableView *view = (MLNTableView *)self.node.targetView;
        UITableView *tView = view.adapter.targetTableView ? view.adapter.targetTableView : view.innerTableView;
        NSInteger sections = tView.numberOfSections;
        if (sections > 0) {
            for (int i =0; i < sections; i++) {
                row += [tView numberOfRowsInSection:i];
                if (row) {
                    break;
                }
            }
        }
    } else if ([self.node.targetView isKindOfClass:[MLNCollectionView class]]) {
        MLNCollectionView *view = (MLNCollectionView *)self.node.targetView;
        UICollectionView *cView = view.adapter.collectionView ? view.adapter.collectionView : view.innerCollectionView;
        NSInteger sections = cView.numberOfSections;
        if (sections > 0) {
            for (int i =0; i < sections; i++) {
                row += [cView numberOfItemsInSection:i];
                if (row) {
                    break;
                }
            }
        }
    } else {
        row = 1;
    }
    hasSubView = (row != 0);
    return hasSubView;
}

- (BOOL)nodeIsGone {
    BOOL isGone = self.node.isGone;
    return isGone;
}

- (void)innerRestart {
    [self stop];
    [self innerStart];
}

- (NSDictionary*)setupLogInfo {
    NSNumber *isWhite = self.isWhite ? @(1) : @(0);
    NSDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         self.item.url,@"url",
                         @(self.detectTime),@"detectTimes",
                         isWhite,@"isWhite",
                         nil];
    return dic;
}

@end
