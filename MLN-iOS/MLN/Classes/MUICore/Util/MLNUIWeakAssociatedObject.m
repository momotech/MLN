//
//  MLNUIWeakAssociatedObject.m
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIWeakAssociatedObject.h"

@implementation MLNUIWeakAssociatedObject

+ (instancetype)weakAssociatedObject:(id)associatedObject
{
    MLNUIWeakAssociatedObject *wp = [[MLNUIWeakAssociatedObject alloc] initWithAssociatedObject:associatedObject];
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
