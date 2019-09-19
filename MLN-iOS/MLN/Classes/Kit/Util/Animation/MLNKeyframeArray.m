//
//  MLNKeyframeArray.m
//  MLN
//
//  Created by MoMo on 2019/9/8.
//

#import "MLNKeyframeArray.h"

@interface MLNKeyframeArray () <MLNKeyframeArrayDelegate> {
    NSUInteger _count;
}
@property (nonatomic, strong) NSArray *innerArray;

@end

@implementation MLNKeyframeArray

- (instancetype)initWithCount:(NSUInteger)count delegate:(id<MLNKeyframeArrayDelegate>)delegate
{
    if (self = [super init]) {
        _count = count;
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    if (self = [super init]) {
        _innerArray = [NSArray arrayWithObjects:objects count:cnt];
        _delegate = self;
    }
    return self;
}

- (NSUInteger)count
{
    return _count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.delegate keyframeArray:self objectAtIndex:index];
}

- (nonnull id)keyframeArray:(nonnull MLNKeyframeArray *)array objectAtIndex:(NSUInteger)index {
    return [self.innerArray objectAtIndex:index];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    MLNKeyframeArray *copyArray = [[self.class allocWithZone:zone] initWithCount:_count delegate:_delegate];
    copyArray.innerArray = self.innerArray.copy;
    return copyArray;
}

@end
