//
//  IvarCoderTests.m
//  IvarCoder
//
//  Created by KUROSAKI Ryota on 2014/07/02.
//  Copyright (c) 2014 SI Agency Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSCoder+SIAIvarCoder.h"
#import "AClass.h"
#import "BClass.h"

@interface IvarCoderTests : XCTestCase
@property (nonatomic) AClass *object;
@end

@implementation IvarCoderTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _object = [[AClass alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _object = nil;
    [super tearDown];
}

- (void)testArchiveUnarchive
{
    self.object.array       = [[NSArray alloc] initWithObjects:@"a", @"b", nil];
    self.object.object      = [NSURL URLWithString:@"http://www.google.com/"];
    self.object.cls         = [NSFileManager class];
    self.object.sel         = @selector(init);
    self.object.yesOrNo     = YES;
    self.object.ucharv      = 'A';
    self.object.intv        = 11;
    self.object.uintv       = 22;
    self.object.shortv      = 33;
    self.object.ushortv     = 44;
    self.object.longv       = 55L;
    self.object.ulongv      = 66LU;
    self.object.longlongv   = 77LL;
    self.object.ulonglongv  = 88LLU;
    self.object.floatv      = 99.9f;
    self.object.doublev     = 12.345f;
    self.object.boolv       = false;
    self.object.charpointer = "hijklmn";
    self.object.integerv    = 6789;
    self.object.uintegerv   = 1234;
    self.object.rectv       = CGRectMake(1, 2, 3, 4);
    self.object.sizev       = CGSizeMake(5, 6);
    self.object.pointv      = CGPointMake(7, 8);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    AClass *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqualObjects(object.array, self.object.array);
    XCTAssertEqualObjects(object.object,self.object.object);
    XCTAssertEqual(object.cls,          self.object.cls);
    XCTAssertEqual(object.sel,          self.object.sel);
    XCTAssertEqual(object.yesOrNo,      self.object.yesOrNo);
    XCTAssertEqual(object.ucharv,       self.object.ucharv);
    XCTAssertEqual(object.intv,         self.object.intv);
    XCTAssertEqual(object.uintv,        self.object.uintv);
    XCTAssertEqual(object.shortv,       self.object.shortv);
    XCTAssertEqual(object.ushortv,      self.object.ushortv);
    XCTAssertEqual(object.longv,        self.object.longv);
    XCTAssertEqual(object.ulongv,       self.object.ulongv);
    XCTAssertEqual(object.longlongv,    self.object.longlongv);
    XCTAssertEqual(object.ulonglongv,   self.object.ulonglongv);
    XCTAssertEqual(object.floatv,       self.object.floatv);
    XCTAssertEqual(object.doublev,      self.object.doublev);
    XCTAssertEqual(object.boolv,        self.object.boolv);
    XCTAssertEqual(object->psz[0],      '\0');
    XCTAssert(strcmp(object.charpointer,self.object.charpointer) == 0);
    XCTAssertEqual(object.voidp,        NULL);
    XCTAssertEqual(object.integerv,     self.object.integerv);
    XCTAssertEqual(object.uintegerv,    self.object.uintegerv);
    XCTAssert(CGRectEqualToRect(object.rectv, self.object.rectv));
    XCTAssert(CGSizeEqualToSize(object.sizev, self.object.sizev));
    XCTAssert(CGPointEqualToPoint(object.pointv, self.object.pointv));
}

- (void)testObjectNil
{
    self.object.array = nil;
    self.object.object = nil;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    AClass *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertNil(object.array);
    XCTAssertNil(object.object);
}

- (void)testCStringNull
{
    self.object.charpointer = NULL;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    AClass *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(object.charpointer, NULL);
}

- (void)testPointer
{
    self.object.voidp = (__bridge void *)self;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    AClass *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(object.voidp, NULL);
}

- (void)testCArray
{
    strncpy(_object->psz, "test_string", 11);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    AClass *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(object->psz[0], '\0');
}

- (void)testNonSupportStruct
{
    self.object.astructv = (AStruct){.num1 = 4444, .num2 = 8888};

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    AClass *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssert(AStructEqualToAStruct(object.astructv, (AStruct){.num1 = 0, .num2 = 0}));
}

- (void)testIgnore
{
    BClass *object = [[BClass alloc] init];
    object.object = @"abc";
    object.integerv = 10;
    object.ignoreObject = @"def";
    object.ignoreIntegerv = 20;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    BClass *unarchiveObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqualObjects(unarchiveObject.object, object.object);
    XCTAssertEqual(unarchiveObject.integerv, object.integerv);
    XCTAssertNil(unarchiveObject.ignoreObject);
    XCTAssertEqual(unarchiveObject.ignoreIntegerv, 0);
}

@end
