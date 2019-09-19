//
//  MLNQRCodeDefaultInfo.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#import "MLNQRCodeDefaultInfo.h"

@implementation MLNQRCodeDefaultInfo

@synthesize date = _date;
@synthesize iconName = _iconName;
@synthesize link = _link;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _link = [aDecoder decodeObjectForKey:@"link"];
        _iconName = [aDecoder decodeObjectForKey:@"iconName"];
        _date = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.link forKey:@"link"];
    [coder encodeObject:self.date forKey:@"date"];
    if (self.iconName) {
        [coder encodeObject:self.iconName forKey:@"iconName"];
    }
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[MLNQRCodeDefaultInfo class]]) {
        return NO;
    }
    return [self.link isEqualToString:[(MLNQRCodeDefaultInfo *)object link]];
}

- (NSUInteger)hash
{
    return self.link.hash;
}

@end
