//
//  BClass.m
//  IvarCoder
//
//  Created by KUROSAKI Ryota on 2014/07/04.
//  Copyright (c) 2014 SI Agency Inc. All rights reserved.
//

#import "BClass.h"

#import "NSCoder+SIAIvarCoder.h"

@implementation BClass

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [coder sia_decodeInstanceVariables:self ofClass:[BClass class] ignore:&_ignoreObject, &_ignoreIntegerv, NULL];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder sia_encodeInstanceVariables:self ofClass:[BClass class] ignore:&_ignoreObject, &_ignoreIntegerv, NULL];
}

@end
