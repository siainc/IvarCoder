//
//  TestClass.m
//  IvarCoder
//
//  Created by KUROSAKI Ryota on 2011/08/30.
//  Copyright (c) 2011 SI Agency Inc. All rights reserved.
//

#import "AClass.h"

#import "NSCoder+SIAIvarCoder.h"

BOOL AStructEqualToAStruct(AStruct struct1, AStruct struct2)
{
    return struct1.num1 == struct2.num1 && struct1.num2 == struct2.num2;
}

@implementation AClass

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [coder sia_decodeInstanceVariables:self ofClass:[AClass class]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder sia_encodeInstanceVariables:self ofClass:[AClass class]];
}

@end
