//
//  MLNWeakAssociatedObject.m
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNWeakAssociatedObject.h"

@implementation MLNWeakAssociatedObject

+ (instancetype)weakAssociatedObject:(id)associatedObject
{
    MLNWeakAssociatedObject *wp = [[MLNWeakAssociatedObject alloc] initWithAssociatedObject:associatedObject];
    return wp;
}

- (instancetype)initWithAssociatedObject:(id)associatedObject
{
    if (self = [super init]) {
        _associatedObject = associatedObject;
    }
    return self;
}

- (void)updateAssociatedObject:(id)associatedObject
{
    _associatedObject = associatedObject;
}

@end
