//
// Created by momo783 on 2020/5/18.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import "NSObject+Hash.h"
#import <objc/runtime.h>

static char kMLAObjectHash;
static NSUInteger mla_hash_index = 0;

@implementation NSObject (Hash)

- (NSUInteger)mla_hash {
    NSUInteger hash = [objc_getAssociatedObject(self, &kMLAObjectHash) unsignedIntegerValue];
    if (hash == 0) {
        hash = ++mla_hash_index;
        if (mla_hash_index == NSUIntegerMax) {
            mla_hash_index = 0;
        }
        objc_setAssociatedObject(self, &kMLAObjectHash, @(hash), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return hash;
}

@end
