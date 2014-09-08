//
//  TestClass.h
//  IvarCoder
//
//  Created by KUROSAKI Ryota on 2011/08/30.
//  Copyright (c) 2011 SI Agency Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct AStruct {
    NSInteger num1;
    NSInteger num2;
} AStruct;

BOOL AStructEqualToAStruct(AStruct struct1, AStruct struct2);


@interface AClass : NSObject <NSCoding>
{
    @public
    char psz[100];
}

@property (nonatomic) NSArray            *array;
@property (nonatomic) id                 object;
@property (nonatomic) Class              cls;
@property (nonatomic) SEL                sel;
@property (nonatomic) BOOL               yesOrNo;
@property (nonatomic) unsigned char      ucharv;
@property (nonatomic) int                intv;
@property (nonatomic) unsigned int       uintv;
@property (nonatomic) short              shortv;
@property (nonatomic) unsigned short     ushortv;
@property (nonatomic) long               longv;
@property (nonatomic) unsigned           ulongv;
@property (nonatomic) long long          longlongv;
@property (nonatomic) unsigned long long ulonglongv;
@property (nonatomic) float              floatv;
@property (nonatomic) double             doublev;
@property (nonatomic) bool               boolv;
@property (nonatomic) char               *charpointer;
@property (nonatomic) void               *voidp;
@property (nonatomic) NSInteger          integerv;
@property (nonatomic) NSUInteger         uintegerv;
@property (nonatomic) CGRect             rectv;
@property (nonatomic) CGSize             sizev;
@property (nonatomic) CGPoint            pointv;
@property (nonatomic) AStruct            astructv;
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
@property (nonatomic) NSRect             nsrectv;
@property (nonatomic) NSSize             nssizev;
@property (nonatomic) NSPoint            nspointv;
#endif

@end
